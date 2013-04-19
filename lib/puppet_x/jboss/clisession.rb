# == Manages CliSession with Open3 

require 'pathname'
require 'open3'
require Pathname.new(__FILE__).dirname.expand_path


class CliSession

  #private_class_method :new

  @@pool = {}

  @stdin
  @stdout
  @stderr
  @connect

  def initialize(array)
    @connect = to_cmd(array)
    @stdin, @stdout, @stderr = Open3.popen3(@connect)
    thread = Thread.new(@stderr) do |stderr|
      while (line = stderr.gets)
        Puppet.error(line)
        puts "stderr: #{line}"
      end
      Puppet.debug("Stderr listener thread ended for #{@connect}")
    end
    Puppet.info("Created a new CliSession for #{@connect}")
    ObjectSpace.define_finalizer( self, self.class.method(:finalize))
  end

  def self.finalize()
    @stdin.close()
    @stdout.close()
    @stderr.close()
    thread.run()
    thread.join()
  end

  def self.get_instance( array )
    session =  @@pool[array.inspect]
    if( session == nil )
      session = new( array )
      @@pool.store(array.inspect, session)
    end
    return session
  end

  def run(cmd)
    Puppet.debug("About to run command: #{cmd} within #{@connect}")
    @stdin.puts(cmd)
    #Puppet.trace("Command sent #{cmd}")
    #line = nonblocking_readline(@stdout)
    # throw away the first line because it is only the echo
    line = @stdout.gets()
    #Puppet.debug("Line read #{line}")
    #result = line
    result = ''
    while( line.index('}') != 0 and line !~ /^\{.*\}$/ ) do
      #line = nonblocking_readline(@stdout)
      line = @stdout.gets()
      #Puppet.debug("Line read #{line}")
      result += line
    end
    #Puppet.debug("Runned command: #{cmd} within #{@connect} returned #{result}")
    return result
  end

  def to_cmd( array )
    cmd = ''
    array.each do |value|
      cmd += value + ' '
    end
    return cmd
  end


  def nonblocking_readline(io, timeout=1)
    result = ""
    while true do
      begin
        char = io.read_nonblock(1)
        result += char
        if (char[0] == 10 or char[0] == 13 )
          return result
        end
      rescue Errno::EAGAIN
        select_result = IO.select([io], nil, nil, timeout)
        if (select_result == nil)
          return result
        end
        retry
      rescue EOFError
        return result
      end
    end
  end

end
