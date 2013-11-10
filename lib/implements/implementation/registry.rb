# encoding: utf-8

module Implements
  module Implementation
    # A registry of implementations, held by an interface.
    class Registry
      def initialize(interface)
        @interface = interface
        @data = []
      end

      def elements(selectors)
        Enumerator.new do |yielder|
          Array(selectors).product(@data.reverse) do |selector, element|
            next unless element.match?(selector)
            yielder << element
          end
        end
      end

      def register(implementation, options, check)
        @data << Element.new(implementation, options, check)
      end

      # An Element in a Registry
      class Element
        def initialize(implementation, options, check)
          @implementation = implementation
          @options = options
          @check = check
        end
        attr_reader :implementation

        def match?(selector)
          true
        end

        def check?(*args)
          return true unless @check
          @check.call(*args)
        end
      end

      # A Finder, plumbed to a Registry.
      class Finder
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
               "#{self}: no compatible implementation.")
        end

        def new(*args, &block)
          implementation = find(*args)
          implementation.new(*args, &block)
        end
      end
    end
  end
end
