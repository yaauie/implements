# encoding: utf-8

module Implements
  # Interface: mix into your interfaces.
  module Interface
    def self.included(base)
      base && fail(ScriptError, "#{self} supports only extend, not include.")
    end

    def self.extended(base)
      base.instance_variable_set(:@implementations,
                                 Implementation::Registry.new(base))
    end

    def register(implementation, options, &block)
      @implementations.register(implementation, options, block)
    end

    def new(*args, &block)
      find_and_instantiate(:auto, *args, &block)
    end

    def find_and_instantiate(selector, *args, &block)
      implementation(selector).new(*args, &block)
    end

    def implementation(selectors = :auto)
      Implementation::Registry::Finder.new(@implementations, selectors)
    end
  end
end
