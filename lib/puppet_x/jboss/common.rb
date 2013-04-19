# == Comands and utils:  Contain methods often used in our custom providers.

require 'pathname'
require Pathname.new(__FILE__).dirname.dirname.dirname.dirname.expand_path + 'lib/puppet_x/jboss/flathash'
require Pathname.new(__FILE__).dirname.dirname.dirname.dirname.expand_path + 'lib/puppet_x/jboss/unorderedarray'
require Pathname.new(__FILE__).dirname.expand_path
require Pathname.new(__FILE__).dirname.dirname.dirname.dirname.expand_path + 'lib/puppet_x/jboss/clisession'

module PuppetX::Jboss
  def self.ip_instance(nic)
    fact_nic_name = "ipaddress_#{nic.gsub(':', '_')}"
    if fact_nic_name.empty? or Facter[fact_nic_name].nil?
      fail("Please verify if the network interface #{nic} exists !")
    end
    return Facter.value(fact_nic_name)
  end

  def self.run_command(cmd)
    # CliSession handles a cli session cache. A session is identified by the
    # engine path, the nic and the '-c' modifier which are all passed in this
    # array as the first 3 values. cmd[3] contains the CLI command
    # TODO This has been done for legacy code compatibility reasons, we could
    # probably handled it with 3+1 params instead.
    session = CliSession.get_instance(cmd[0..2])
    result = session.run(cmd[3])
    return result
  end

  # Run a JBoss CLI command
  #
  # [*engine_path*]
  #   A String, which contains the JBoss EAP 6 engine path.
  #   Used to locate the jboss-cli.sh script usually found under bin/ directory.
  #
  # [*nic*]
  #   A String, which is the name of the Network Interface Card which holds
  #   the IP adress of the JBoss instance on which we want to run command
  #   against.
  #
  # [*path*]
  #   A String, which is the CLI path following the CLI syntax.
  #   ex : "/subsystem=logging/logger=tartenpion"
  #
  # [*operation*]
  #   A String, which is the CLI operation name to execute.
  #   ex : "add", "remove", "read-resource", "write-attribute",
  #   "undefine-attribute"
  #
  # [*params*]
  #   A String, which contains the CLI parameters to use whith the given CLI
  #   path and CLI operation name.
  #   Can be an empty string if the given CLI operation doesn't require any
  #   parameters.
  #
  def self.run_cli_command(engine_path, nic, path, operation, params='')
    cmd = [ "#{engine_path}/bin/jboss-cli.sh", "-c", "--controller=#{ip_instance("#{nic}")}", "#{path}:#{operation}\(#{params}\)" ]
    run_command( cmd )
  end

  # Run multiple JBoss CLI command.
  #
  # [*engine_path*]
  #   A String, which contains the JBoss EAP 6 engine path.
  #   Used to locate the jboss-cli.sh script usually found under bin/ directory.
  #
  # [*nic*]
  #   A String, which is the name of the Network Interface Card which holds
  #   the IP adress of the JBoss instance on which we want to run command
  #   against.
  #
  # [*path*]
  #   The attribute path following the CLI syntax.
  #
  # [*commands*]
  #   An Array, where each cell is a String, which contains a JBoss CLI command
  #   (CLI path + CLI operation name + CLI parameters).
  #
  def self.run_cli_commands(engine_path, nic, commands=[])
    if commands == nil or commands.empty?()
      return
    end
    commands.each do |line|
      cmd = [ "#{engine_path}/bin/jboss-cli.sh", "-c", "--controller=#{ip_instance("#{nic}")}", "#{line}" ]
        begin
          run_command(cmd)
        rescue Puppet::ExecutionFailure => e
          Puppet.debug(e)
        end
    end
  end

  # Converts the given Typed value into a the JBoss CLI format.
  # Currently, supports boolean (:true/:false), Numbers, String, Hash  and :nil.
  # Ex :
  #   - the Boolean :true will be replaced by 'true' ;
  #   - the Number 1234 will be replace by '1234' ;
  #   - the String "1234" will be replaced by '"12345"' ;
  #   - the Hash {:key1=>"value1", :key2=>int2} will be replaced by '(key1="value1", key2=int2)' ;
  #   - the null value :nil will be replaced by 'undefined' ;
  #
  # TODO : should escape " in string ?
  # TODO : special characeter conversion ?
  #
  # [*output*]
  #   A String, which contains data in a format which is compatible with the
  #   JBoss CLI format.
  #
  def self.to_cli_value(value)
    case value
    when :nil
      return 'undefined'
    when :false
      return 'false'
    when :true
      return 'true'
    when Fixnum
      return "#{value}"
    when FlatHash
      return value.to_s
    when Array
      return array_to_string(value)
    when Hash
      raise "CLI values must be set inside a FlatHash instead of Hash to be converted to their CLI equivalent"
    else
      return "\"#{value}\""
    end
  end

  def self.array_to_string(new_value)
    result = ""
    new_value.each do |value|
      result += to_cli_value(value) + ","
    end
    return result = "[" + result.chomp(",") + "]"
  end

  def self.to_cli_boolean(value)
    case value
    when true, "true", :true, 'true'
      return :true
    else
      return :false
    end
  end

  def self.to_boolean(value)
    case value
    when true, "true", :true, 'true'
      return true
    else
      return false
    end
  end

  #  Parses CLI command output to extract a map of results.
  #
  # [*output*]
  #   A Hash containing a JBoss CLI command output, where each entry
  #   is one of :
  #   - "key" => :nil if the key is undefined ;
  #   - "key" => "String" (ex : "key" => "a string") ;
  #   - "key" => Integer (ex : "key" => 12345678) ;
  #   - "key" => :true / :false (ex : "key" => :false) ;
  #   - "key" => Hash ;
  #   - "key" => Array (TODO)
  #
  def self.parse_cli_result_as_map(output)
    # Load '/opt/puppet/lib/ruby/gems/1.8/gems/multi_json-1.7.1/lib/multi_json.rb'
    require 'multi_json'
    # Removes trailing 'L' on Long CLI values to allow mutli_json to parse them
    # \1 is the group matching [0-9]+
    # \2 is the group matching the EOL or ','
    output = output.gsub(/=> ([0-9]+)L(,|\s*\})/,'=> \1\2')
    # Replace Undefined CLI values by a Magic String, so that multi_json can parse it.
    # Note that the method 'to_strongly_typed_hash will' will later convert our
    # Magic String to :nil.
    output = output.gsub(/=> undefined(,|\s*\})/,'=> "__undefined__"\1')
    # Replaces
    #    "module-options" => [
    #      ("debug" => "true"),
    #      ("doNotPrompt" => "true")
    #    ]
    # into
    #    "module-options" => {
    #      "debug" => "true",
    #      "doNotPrompt" => "true"
    #    }
    #
    # Matches - on multiple lines - Arrays in the form '[ entry(,entry)* ]', where entry
    # is '("key"=>"value")', and replace them by '{ entry(,entry)* }'
    output = output.gsub(/\[(\s*\([^\(\)\[\]]*\)(,\s*\([^\(\)\[\]]*\))*\s*)\]/m) do
      array_group = $1
      # Matches entries in the form '("key"=>"value")' and replace them by '"key"=>"value"'
      result = array_group.gsub(/\(([^\(\)]*)\)/) do
        key_group = $1
      end
      "{" + result + "}"
    end

    # Failure description is on several lines: We put in one line
    failure_description = output.gsub(/.*("failure-description" => ".*[^\\]",).*/m,'\1')
    oneline_failure_description = failure_description.gsub(/[\r\n]/,'')
    output = output.gsub(failure_description, oneline_failure_description)

    output = output.gsub('=>',':')
    hash = MultiJson.decode(output)
    outcome = hash['outcome']
    # If the outcome is 'failed', we raise an ExecutionFailure exception which
    # is handled in exists?() methods of JBoss_cli providers
    if( outcome == 'failed' )
      raise Puppet::ExecutionFailure.new(hash['failure-description']) 
    end
    return to_strongly_typed_hash(hash['result'])
  end

  # Convert cli raw values in the given hash to strongly typed values.
  # If the value is an Hash, convert it (recurs call).
  #
  # [*output*]
  #   A Hash containing a JBoss CLI command output, where each entry
  #   is one of :
  #   - "key" => :nil if the key is undefined ;
  #   - "key" => "String" (ex : "key" => "a string") ;
  #   - "key" => Integer (ex : "key" => 12345678) ;
  #   - "key" => :true / :false (ex : "key" => :false) ;
  #   - "key" => Hashi ;
  #   - "key" => Array (TODO)
  #
  def self.to_strongly_typed_hash(cli_hash)
    if cli_hash.nil?
      return :nil
    end
    cli_hash.each do |key, value|
      case value
      when "__undefined__"
        cli_hash[key] = :nil
      when true
        cli_hash[key] = :true
      when false
        cli_hash[key] = :false
      when Hash
        cli_hash[key] = to_strongly_typed_hash(value)
      end
    end
    return cli_hash
  end

  # Run the given JBoss CLI command on the given JBoss instance and parses CLI
  # command output to extract a map of results.
  #
  # [*engine_path*]
  #   A String, which contains the JBoss EAP 6 engine path.
  #   Used to locate the jboss-cli.sh script usually found under bin/ directory.
  #
  # [*nic*]
  #   A String, which is the name of the Network Interface Card which holds
  #   the IP adress of the JBoss instance on which we want to run command
  #   against.
  #
  # [*path*]
  #   A String, which is the CLI path following the CLI syntax.
  #   ex : "/subsystem=logging/logger=tartenpion"
  #
  # [*operation*]
  #   A String, which is the CLI operation name to execute.
  #   ex : "add", "remove", "read-resource", "write-attribute",
  #   "undefine-attribute"
  #
  # [*params*]
  #   A String, which contains the CLI parameters to use whith the given CLI
  #   path and CLI operation name.
  #   Can be an empty string if the given CLI operation doesn't require any
  #   parameters.
  #
  # [*output*]
  #   A Hash containing a JBoss CLI command output, where each entry
  #   is one of :
  #   - "key" => nil if the key is undefined ;
  #   - "key" => "String" (ex : "key" => "a string") ;
  #   - "key" => Integer (ex : "key" => 12345678) ;
  #   - "key" => :true / :false (ex : "key" => :false) ;
  #   - "key" => Hash
  #
  def self.exec_command(engine_path, nic, path, operation, params='')
    output = run_cli_command(engine_path, nic, path, operation, params)
    return parse_cli_result_as_map(output)
  end

  def self.write_attributes(engine_path, nic, path, current_attrs={}, attrs_to_write={})
    update_attributes(engine_path, nic, path, current_attrs, attrs_to_write)
  end

  def self.add_attributes(engine_path, nic, path, current_attrs=nil, attrs_to_write={})
    if attrs_to_write == nil
      return
    end
    Puppet.debug("Adding attributes --- Current attributes : #{current_attrs.inspect()}")
    Puppet.debug("Adding attributes --- Expected attributes : #{attrs_to_write.inspect()}")

    # Build the 'add' command with each key/value of the given hash
    # (Exclude Nested Hasp, which will be treated later)
    params = ""
    attrs_to_write.each do |key, value|
      if value.is_a?(Hash) and !value.is_a?(FlatHash)
        next
      elsif value != :nil
        params += "," if !params.empty?()
        params += "#{key}=#{to_cli_value(value)}"
      end
    end
    # Remove it first if specified
    begin
      run_cli_command(engine_path, nic, path, "remove") if !params.empty? and current_attrs != nil and !current_attrs.empty?()
    rescue Puppet::ExecutionFailure => e
      Puppet.debug(e)
    end
    # Run the 'add' command if not empty
    begin
      run_cli_command(engine_path, nic, path, "add", params) if !params.empty? or (params.empty? and (current_attrs == nil or current_attrs.empty?))
    rescue Puppet::ExecutionFailure => e
      Puppet.debug(e)
    end

    # Add Nested Hash
    attrs_to_write.each do |nested_key, nested_value|
      if nested_value.is_a?(Hash) and !nested_value.is_a?(FlatHash)
        add_nested_hash(engine_path, nic, path, nested_key, current_attrs == nil ? nil : current_attrs[nested_key], nested_value)
      end
    end
  end

  def self.add_nested_hash(engine_path, nic, path, nested_path, current_attrs={}, attrs_to_write={})
    attrs_to_write.each do |key,value|
      add_attributes(engine_path, nic, path+"/#{nested_path}=#{key}", current_attrs != nil ? current_attrs[key] : nil, value )
    end
  end


  # Write given attributes to the given JBoss instance using JBoss
  # CLI commands.
  # Perform a diff between current and expected attributes, and apply the
  # delta.
  #
  # [*engine_path*]
  #   A String, which contains the JBoss EAP 6 engine path.
  #   Used to locate the jboss-cli.sh script usually found under bin/ directory.
  #
  # [*nic*]
  #   A String, which is the name of the Network Interface Card which holds
  #   the IP adress of the JBoss instance on which we want to run command
  #   against.
  #
  # [*path*]
  #   A String, which is the CLI path following the CLI syntax.
  #   ex : "/subsystem=logging/logger=tartenpion"
  #
  # [*current*]
  #   A Hash, which contains the current attributes values.
  #
  # [*attrs_to_write*]
  #   A Hash, which contains the expected attributes names/values.
  #
  def self.update_attributes(engine_path, nic, path, current_attrs={}, attrs_to_write={})
    if attrs_to_write == nil or attrs_to_write.empty?()
      return
    end
    Puppet.debug("Updating attributes --- Current attributes : #{current_attrs.inspect()}")
    Puppet.debug("Updating attributes --- Expected attributes : #{attrs_to_write.inspect()}")
    cmds = []
    attrs_to_write.each do |key, value|
      if value == :nil and current_attrs.has_key?(key) and current_attrs[key] != :nil
        cmds  << path + ":" + "undefine-attribute" + "(name=#{key})"
      elsif !current_attrs.has_key?(key) or current_attrs[key] != value
        cmds << path + ":" + "write-attribute" + "(name=#{key},value=#{to_cli_value(value)})"
      end
    end
    run_cli_commands(engine_path, nic, cmds)
  end

end

