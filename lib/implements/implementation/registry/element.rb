# encoding: utf-8

module Implements
  # An Element in a Registry
  class Implementation::Registry::Element
    def initialize(implementation, options, check)
      @implementation = implementation
      @options = options
      @check = check
    end
    attr_reader :implementation

    def match?(selector)
      selector = selector.to_s if selector.kind_of?(Symbol)
      selector = selector.dasherize if selector.kind_of?(String)
      @options[:groups].map(&:to_s).any? { |group| selector === group }
    end

    def check?(*args)
      return true unless @check
      @check.call(*args)
    end
  end
end
