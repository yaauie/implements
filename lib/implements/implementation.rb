# encoding: utf-8

require 'active_support/inflector'

require_relative 'implementation/registry'

module Implements
  # Implementation: mix into your implementations
  module Implementation
    # An exception raised when an implementation cannot be found.
    NotFound = Class.new(NotImplementedError)

    private

    def implements(iface, options = {}, &block)
      unless iface.kind_of?(Interface)
        fail(TypeError, 'Argument must be a Implements::Interface')
      end

      groups = Array(options.fetch(:as) { implementation_descriptors(iface) })
      groups << :auto if options.fetch(:auto, true)
      groups << :default unless block_given?
      iface.register_implementation(self, groups: groups, &block)

      include iface
    end

    def implementation_descriptors(interface)
      name = self.name
      name && name.sub(Regexp.new("^#{interface}::"), '').underscore.dasherize
    end
  end
end
