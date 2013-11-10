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
    end
  end
end
