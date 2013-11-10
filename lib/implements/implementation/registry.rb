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
    end
  end
end

require_relative 'registry/element'
require_relative 'registry/finder'
