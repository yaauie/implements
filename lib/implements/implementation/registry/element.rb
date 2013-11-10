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
      true
    end

    def check?(*args)
      return true unless @check
      @check.call(*args)
    end
  end
end
