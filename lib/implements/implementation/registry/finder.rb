# encoding: utf-8

module Implements
  # A Finder, plumbed to a Registry.
  class Implementation::Registry::Finder
    def initialize(registry, selectors)
      @registry = registry
      @selectors = selectors
    end

    def find(*args)
      @registry.elements(@selectors).each do |config|
        next unless config.check?(*args)
        return config.implementation
      end

      fail(Implementation::NotFound,
           "no compatible implementation for #{self}")
    end

    def new(*args, &block)
      implementation = find(*args)
      implementation.new(*args, &block)
    end
  end
end
