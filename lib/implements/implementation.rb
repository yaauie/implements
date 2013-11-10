# encoding: utf-8

require_relative 'implementation/registry'

module Implements
  # Implementation: mix into your implementations
  module Implementation
    # An exception raised when an implementation cannot be found.
    NotFound = Class.new(NotImplementedError)

    private

    def implements(iface, options = {}, &block)
      fail TypeError unless iface.kind_of?(Interface)

      groups = Array(options.fetch(:as) { implementation_descriptors(iface) })
      groups << :auto if options.fetch(:auto, true)
      iface.register(self, groups: groups, &block)

      include iface
    end

    def implementation_descriptors(interface)
      name = self.name
      name && name.sub(Regexp.new("^#{interface}::"), '')
    end
  end
end
