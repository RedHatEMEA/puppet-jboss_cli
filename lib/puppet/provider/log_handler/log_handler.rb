require 'pathname'
require Pathname.new(__FILE__).dirname.dirname.dirname.dirname.expand_path + 'puppet_x/jboss/common'

Puppet::Type.type(:log_handler).provide(:log_handler) do
  include PuppetX::Jboss
  @doc = "Manages the log handlers."

  confine :osfamily => :redhat

  # Returns an empty array to allow handling by
  def self.instances
    return []
  end

  def init
    $attrs_to_write = {}
    $current_attrs = {}
    $engine_path = @resource[:engine_path]
    $nic = @resource[:nic]
    $path = "/subsystem=logging/#{@resource[:type]}=#{@resource[:handler_name]}"
  end

  def exists?
    init()
    begin
      $current_attrs = PuppetX::Jboss.exec_command($engine_path, $nic, $path, "read-resource", "recursive=true")
      return true
    rescue Puppet::ExecutionFailure => e
      return false
    end
  end

  def create
    PuppetX::Jboss.add_attributes($engine_path, $nic, $path, $current_attrs, build_attrs_to_add())
  end

  def destroy
    PuppetX::Jboss.exec_command($engine_path, $nic, $path, "remove")
  end

  def flush
    PuppetX::Jboss.update_attributes($engine_path, $nic, $path, $current_attrs, $attrs_to_write)
  end

  def build_attrs_to_add
    to_add = {}
    to_add["level"] = @resource[:level]
    to_add["formatter"] = @resource[:formatter]
    # add all custom options
    to_add.merge!(@resource[:custom_options]) if @resource[:custom_options] != nil
    # convert the custom option 'file' into a CLI FlatHash
    if @resource[:custom_options] != nil and @resource[:custom_options]["file"] != nil
      to_add["file"] = FlatHash.new(@resource[:custom_options]["file"]) 
    end

    # convert the custom option 'append' into a CLI Boolean (:true/:false)
    to_add["append"] = PuppetX::Jboss.to_boolean(@resource[:custom_options]["append"]) if @resource[:custom_options] != nil and @resource[:custom_options]["append"] != nil

    return to_add
  end

  def level
    return $current_attrs["level"]
  end

  def level=(new_value)
    $attrs_to_write["level"] = new_value
  end

  def formatter
    return $current_attrs["formatter"]
  end

  def formatter=(new_value)
    $attrs_to_write["formatter"] = new_value
  end

  def custom_options
    custom_options = {}
    map = @resource[:custom_options]
    # To avoid overriding already set options not presents in the custom options
    # defined by user, we browse the provided options and only return the
    # current values having the same key
    $current_attrs.each do |key, value|
      if( map[key] != nil )
        custom_options.store(key, value)
      end
    end
    # convert the custom option 'append' into a Boolean (true/false)
    custom_options["append"] = PuppetX::Jboss.to_boolean(custom_options["append"]) if custom_options["append"] != nil
    return custom_options
  end

  def custom_options=(new_value)
    # add all custom options
    $attrs_to_write.merge!(new_value) if new_value != nil
    # convert the custom option 'file' into a CLI FlatHash
    $attrs_to_write["file"] = PuppetX::Jboss.to_cli_flathash(new_value["file"]) if new_value != nil and new_value["file"] != nil
    # convert the custom option 'append' into a CLI Boolean (:true/:false)
    $attrs_to_write["append"] = PuppetX::Jboss.to_cli_boolean(new_value["append"]) if new_value != nil and new_value["append"] != nil
  end

end
