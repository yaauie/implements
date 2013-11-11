# encoding: utf-8

module Implements
  # Interface: mix into your interfaces.
  module Interface
    # Used to find a suitable implementation
    # @api public
    # @param [*selectors] zero or more selectors to use for finding an
    #   implementation of this interface. If none is given, :auto is assumed.
    # @return [Implementation::Registry::Finder]
    def implementation(*selectors)
      selectors << :auto if selectors.empty?
      Implementation::Registry::Finder.new(@implementations, selectors)
    end

    # Returns a list of implementations by resolvable name.
    # @api public
    # @return [Array<String>]
    def list_implementation_names
      @implementations.list_names.map(&:to_s).uniq
    end

    # Find an instantiate a suitable implementation on auto mode
    # @see Implementation::Registry::Find#new
    # @api public
    def new(*args, &block)
      implementation(:auto).new(*args, &block)
    end

    # @api private
    # Used by Implementation#implements
    # @param implements (see Registry#register)
    # @param options (see Registry#register)
    # @param &block (see Registry#register)
    # @return (see Registry#register)
    def register_implementation(implementation, options, &block)
      @implementations.register(implementation, options, block)
    end

    # Bad things happen when used improperly. Make it harder to get it wrong.
    # @api private
    def self.included(base)
      base && fail(ScriptError, "#{self} supports only extend, not include.")
    end

    # Set up the interface.
    # @param base [Module]
    # @api private
    def self.extended(base)
      unless base.instance_of?(Module)
        fail(TypeError, "expected Module, got #{base.class}")
      end

      base.instance_variable_set(:@implementations,
                                 Implementation::Registry.new(base))
    end
  end
end
