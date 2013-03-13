# == Comands and utils:  Contain methods  often used in our custom providers.
#
#
# [*namevar*]
#   Ce paramètre est toujours composé par le nom de l'utilisateur d'instance
#   du nodeid sépar© par un '-'. Ex: i21654m-node
#
# [*ensure*]
#   Ce paramètre permet de gérer l'installation ou la déinstallation
#   l'instance. Les valeurs possibles sont 'present' ou 'absent'.
#
#   - Valeur par défaut: 'present
#

require 'pathname'
require Pathname.new(__FILE__).dirname.expand_path

module PuppetX::Jboss
  def self.ip_instance(nic)
    fact_nic_name = "ipaddress_#{nic.gsub(':', '_')}"
    if fact_nic_name.empty? or Facter[fact_nic_name].nil?
      fail("Please verify if the network interface #{nic} exists !")
    end
    ip_instance = Facter.value(fact_nic_name) if !Facter[fact_nic_name].nil?
    return ip_instance
  end

  # The Puppet::Util::execute method is deprecated in puppet 3.0 and is moving
  # to Puppet::Util::Execution.execute.
  def self.run_command(cmd)
    if Puppet::Util::Execution.respond_to?(:execute)
      exec_method = Puppet::Util::Execution.method(:execute)
    else
      exec_method = Puppet::Util.method(:execute)
    end
    exec_method.call(cmd)
  end

  #  Run a JBoss CLI command
  #
  # [*engine_path*]
  #  The JBoss EAP 6 engine path. Used to locate the jboss-cli.sh script usually
  #  found under bin/ directory.
  #
  # [*nic*]
  #   The name of the Network Interface Card which holds the IP adress of the
  #   JBoss instance on which we  want to run command against.
  #
  # [*path*]
  #   The attribute path following the CLI syntax.
  #
  # [*operation*]
  #   The CLI operation name: Usually one of 'add', 'read-resource', 'remove',
  #   'write-attribute'
  #
  #   [*params*]
  #     The parameters to use whit this operation and this path. Can be an empty
  #     string.
  #
  def self.run_jboss_cli_command(engine_path, nic, path, operation, params)
    cmd = [
      "#{engine_path}/bin/jboss-cli.sh", "-c",
      "--controller=#{ip_instance("#{nic}")}", "--command=#{path}:#{operation}\(#{params}\)"
    ]
    run_command(cmd)
  end

  #  Run multiple JBoss CLI commands
  #
  # [*engine_path*]
  #  The JBoss EAP 6 engine path. Used to locate the jboss-cli.sh script usually
  #  found under bin/ directory.
  #
  # [*nic*]
  #   The name of the Network Interface Card which holds the IP adress of the
  #   JBoss instance on which we  want to run command against.
  #
  # [*path*]
  #   The attribute path following the CLI syntax.
  #
  # [*commands*]
  #  A string containing the full commands. Each command must be separated by a
  #  comma. Trailing  comma is removed.
  #
  def self.run_jboss_cli_commands(engine_path, nic, commands=[])
    cmds = ""
    commands.each do |command|
      cmds += "#{command},"
    end
    cmds = cmds.chomp(",")

    if engine_path.end_with? "6.0.0"
      ### JBoss CLI --commands attribute don't work with comma
      ### separated - Bug AS7-4017. Fixed on EAP 6.0.1
      commands.each do |line|
        cmd = [
          "#{engine_path}/bin/jboss-cli.sh", "-c",
          "--controller=#{ip_instance("#{nic}")}", "--command=#{line}"
        ]
        begin
          run_command(cmd)
        rescue Puppet::ExecutionFailure => e
          Puppet.debug(e)
        end
      end
    else
      cmd = [
        "#{engine_path}/bin/jboss-cli.sh", "-c",
        "--controller=#{ip_instance("#{nic}")}", "--commands=\"#{cmds}\""
      ]
      begin
        run_command(cmd)
      rescue Puppet::ExecutionFailure => e
        Puppet.debug(e)
      end
    end
  end


  # Parses CLI command output to extract a single result.
  #
  # [*output*] A string containing a JBoss CLI command output with an entry 
  # "result" =>  "value" entry.
  #
  def self.parse_single_cli_result(output)
    val = ''
    output.split("\n").collect do |line|
      if line.start_with?("    \"result\"")
        val = line.strip
        val = val.split(" => ")[1]
        if  val.start_with?("\"")
          val = val.sub("\"", "")
        end
        val = val.chomp(",")
        # if val ends with ", it is removed, if not it is not (see chomp)
        val = val.chomp("\"")
      end
    end
    return val
  end
end

