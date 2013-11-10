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
      base.instance_variable_set(:@implementations, [])
    end

    def register(implementation, options, &block)
      @implementations << [implementation, options, block]
    end

    def new(*args, &block)
      @implementations.reverse_each do |implementation, options, check|
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

      interface.register(self, options.dup, &block)

      include interface
    end
  end
end
