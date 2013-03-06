require 'pathname'
require Pathname.new(__FILE__).dirname.dirname.dirname.dirname.expand_path + 'puppet_x/redhat/jboss'

Puppet::Type.type(:vault).provide(:vault) do
  include PuppetX::Redhat
  @doc = "Manages vault (to store sensitive data) with the jboss-cli.sh"

  confine :osfamily => :redhat

  def vault_options
    attributes = {}
    val = ""
    subsys = "/core-service=vault"
    cmd = [
      "#{@resource[:engine_path]}/bin/jboss-cli.sh",
      "-c", "--controller=#{PuppetX::Redhat.ip_instance("#{@resource[:nic]}")}",
      "--command=#{subsys}:read-attribute\(name=vault-options\)"
    ]

    output = PuppetX::Redhat.run_command(cmd)
    output.split("\n").collect do |line|
       val = line.delete(" ")
       if ! (val.start_with?("\"outcome\"") or
             val.start_with?("\"result\"")  or
             val.start_with?("}]")          or
             val.start_with?("{")           or
             val.start_with?("}")          )
         val = val.split("=>")
         mykey = val[0].delete("\"")
         mykey = mykey.gsub(".", "-")
         myval = val[1].delete("\"")
         myval = myval.chomp(",")
         attributes.store(mykey, myval)
       end
    end
    hashparams = create_hash_from_param
    if hashparams != attributes
      update_vault_options
    end
  end

  def create_hash_from_param
    debug "Create Hash from parameters type"
    params = { "ENC_FILE_DIR"=>"#{@resource[:enc_file_dir]}",
               "KEYSTORE_URL"=>"#{@resource[:keystore_url]}",
               "KEYSTORE_PASSWORD"=>"#{@resource[:keystore_password]}",
               "KEYSTORE_ALIAS"=>"#{@resource[:keystore_alias]}",
               "SALT"=>"#{@resource[:salt]}",
               "ITERATION_COUNT"=>"#{@resource[:iteration_count]}"
             }
    return params
  end

  def update_vault_options
    debug "Update existing vault-options properties"
    subsys = "/core-service=vault"

    cmd = [
      "#{@resource[:engine_path]}/bin/jboss-cli.sh",
      "-c", "--controller=#{PuppetX::Redhat.ip_instance("#{@resource[:nic]}")}",
      "--command=#{subsys}:write-attribute\(name=vault-options,value={ \
                 \"ENC_FILE_DIR\"=>\"#{@resource[:enc_file_dir]}\", \
                 \"KEYSTORE_URL\"=>\"#{@resource[:keystore_url]}\", \
                 \"KEYSTORE_PASSWORD\"=>\"#{@resource[:keystore_password]}\", \
                 \"KEYSTORE_ALIAS\"=>\"#{@resource[:keystore_alias]}\", \
                 \"SALT\"=> \"#{@resource[:salt]}\" , \
                 \"ITERATION_COUNT\"=>\"#{@resource[:iteration_count]}\" \
             }\)"
    ]

    debug "Updating vault configuration"
    PuppetX::Redhat.run_command(cmd)
    notice "Updating  vault configuration #{@resource[:name]}"
  end

  def create
    subsys = "/core-service=vault"
    cmd = [
      "#{@resource[:engine_path]}/bin/jboss-cli.sh",
      "-c", "--controller=#{PuppetX::Redhat.ip_instance("#{@resource[:nic]}")}",
      "--command=#{subsys}:add\(vault-options={ \
                  \"ENC_FILE_DIR\"=>\"#{@resource[:enc_file_dir]}\", \
                  \"KEYSTORE_URL\"=>\"#{@resource[:keystore_url]}\", \
                  \"KEYSTORE_PASSWORD\"=>\"#{@resource[:keystore_password]}\", \
                  \"KEYSTORE_ALIAS\"=>\"#{@resource[:keystore_alias]}\", \
                  \"SALT\"=> \"#{@resource[:salt]}\" , \
                  \"ITERATION_COUNT\"=>\"#{@resource[:iteration_count]}\" \
             }\)"
    ]
    debug "Creating vault"
    PuppetX::Redhat.run_command(cmd)
  end

  def destroy
    debug "Destroying vault"
    subsys = "/core-service=vault"
    cmd = [
      "#{@resource[:engine_path]}/bin/jboss-cli.sh",
      "-c", "--controller=#{PuppetX::Redhat.ip_instance("#{@resource[:nic]}")}",
      "--command=#{subsys}:remove"
    ]
    PuppetX::Redhat.run_command(cmd)
  end

  def exists?
    subsys = "/core-service=vault"
    cmd = [
      "#{@resource[:engine_path]}/bin/jboss-cli.sh",
      "-c", "--controller=#{PuppetX::Redhat.ip_instance("#{@resource[:nic]}")}",
      "--command=#{subsys}:read-resource"
    ]
    begin
      PuppetX::Redhat.run_command(cmd)
      vault_options
      true
    rescue Puppet::ExecutionFailure => e
      false
    end
  end
end
