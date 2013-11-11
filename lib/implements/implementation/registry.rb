# encoding: utf-8

require 'set'

module Implements
  module Implementation
    # A registry of implementations, held by an interface.
    # @api private
    class Registry
      # @api private
      # @param interface [Interface]
      def initialize(interface)
        @interface = interface
        @elements = []
      end
      attr_reader :interface

      # Returns an enumerator of elements matching the given selectors,
      # in the order specified; this is used by {Finder#find}.
      # @param selectors [#to_s, Array<#to_s>] - one or more selectors
      # @return [Enumerator<Element>]
      def elements(selectors)
        Enumerator.new do |yielder|
          yielded = Set.new
          Array(selectors).product(@elements) do |selector, element|
            next unless element.match?(selector)
            yielder << element if yielded.add?(element)
          end
        end
      end

      # @api private
      # @return [Array<String>]
      def list_names
        @elements.map(&:name).compact
      end

      # @api private
      # @param implementation [Implementation]
      # @param options [Hash{Symbol=>Object}] (see: Element#initialize)
      # @param check [#call, nil]
      def register(implementation, options, check)
        @elements.unshift Element.new(self, implementation, options, check)
      end
    end
  end
end

require_relative 'registry/element'
require_relative 'registry/finder'
