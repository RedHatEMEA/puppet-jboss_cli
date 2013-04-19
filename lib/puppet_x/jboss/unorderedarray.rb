# == Comands and utils:  Contain methods often used in our custom providers.

require 'pathname'
require Pathname.new(__FILE__).dirname.expand_path


# An Array implementation which does not take care about order while comparing
# Arrays
class Puppet::Property::UnorderedArray < Puppet::Property
  def insync?(is)
    Puppet.info(is.inspect)
    Puppet.info(@should.inspect)
    if( is != :nil and is != nil )
      is.sort == @should.sort
    end
  end
end
