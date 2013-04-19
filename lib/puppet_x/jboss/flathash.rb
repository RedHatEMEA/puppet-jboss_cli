# == Comands and utils:  Contain methods often used in our custom providers.

require 'pathname'
require Pathname.new(__FILE__).dirname.expand_path
require Pathname.new(__FILE__).dirname + 'common'

# An subclass of Hash to manage cli conversion for some types
class FlatHash < Hash

  def initialize( hash = {})
    super()
    self.merge!(hash)
  end

  def to_s
    # Converts a hash into its equivalent respecting CLI syntax. Supports nested
    # hashes.
    result = ""
    self.each do |key,value|
      result += "\"#{key}\"=>" + PuppetX::Jboss.to_cli_value(value) + ","
    end
    return result = "{" +result.chomp(",") + "}"
  end

end
