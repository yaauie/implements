# encoding: utf-8
require 'implements/version'

# Tools for Interfaces.
module Implements
  # Interface: mix into your interfaces.
  module Interface
    def self.included(base)
      base && fail(ScriptError, "#{self} supports only extend, not include.")
    end

    def self.extended(base)
      hsh = Hash.new { |hash, key| hash[key] = [] }
      base.instance_variable_set(:@implementations, hsh)
    end

    def register(implementation, options, &block)
      [:auto, options[:names]].flatten.compact.each do |group|
        @implementations[group] << [implementation, options, block]
      end
    end

    def new(*args, &block)
      @implementations[:auto].reverse_each do |implementation, options, check|
        unless check && !check.call(*args, &block)
          return implementation.new(*args, &block)
        end
      end
      fail(Implementation::NotFound, "#{self}: no compatible implementation.")
    end
  end

  # Implementation: mix into your implementations
  module Implementation
    # An exception raised when an implementation cannot be found.
    NotFound = Class.new(NotImplementedError)

    private

    def implements(interface, options = {}, &block)
      fail TypeError unless interface.kind_of?(Interface)

      names = options.fetch(:as) { implementation_descriptors(interface) }
      interface.register(self, names: Array(names), &block)

      include interface
    end

    def implementation_descriptors(interface)
      name = self.name
      name && name.sub(Regexp.new("^#{interface}::"), '')
    end
  end
end
