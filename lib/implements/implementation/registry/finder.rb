# encoding: utf-8

module Implements
  # A Finder, plumbed to a Registry.
  # @api private
  class Implementation::Registry::Finder
    # @api private
    # @param registry [Implementation::Registry]
    # @param selectors [Array<#===>] Typically an array of strings
    def initialize(registry, selectors)
      @registry = registry
      @selectors = selectors
    end

    # Returns an instance of the @registry.interface that supports the given
    # arguments.
    # @api private
    def new(*args, &block)
      implementation = find(*args)
      implementation.new(*args, &block)
    end

    # Find a suitable implementation of the given interface,
    # given the args that would be passed to its #initialize
    # and our selectors
    # @api private
    def find(*args)
      @registry.elements(@selectors).each do |config|
        next unless config.check?(*args)
        return config.implementation
      end

      fail(Implementation::NotFound,
           "no compatible implementation for #{inspect}")
    end

    # @api private
    def inspect
      "<#{@registry.interface}::implementation(#{@selectors.join(', ')})>"
    end
  end
end
