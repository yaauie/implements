# encoding: utf-8

module Implements
  # An Element in a Registry
  # @api private
  class Implementation::Registry::Element
    # @api private
    # @param registry [Implementation::Registry]
    # @param implementation [Implementation]
    # @param options [Hash{Symbol=>Object}]
    # @param check [#call, nil]
    def initialize(registry, implementation, options, check)
      @registry = registry
      @implementation = implementation
      @options = options
      @check = check
    end
    attr_reader :implementation

    # @api private
    # @param selector [#===]
    # @return [Boolean]
    def match?(selector)
      selector = selector.to_s if selector.kind_of?(Symbol)
      selector = selector.dasherize if selector.kind_of?(String)
      groups.map(&:to_s).any? { |group| selector === group }
    end

    # Check the implementation agains the args that would be used
    # to instantiate it.
    # @api private
    # @params *args [Array<Object>]
    # @return [Boolean]
    def check?(*args)
      return true unless @check
      @check.call(*args)
    end

    # @api private
    # @return [String]
    def name
      groups.first
    end

    private

    # @api private
    # @return [Array<String>]
    def groups
      @groups ||= [@options[:name],
                   implementation_descriptors,
                   @options[:groups]].flatten.compact.map(&:to_s)
    end

    # @api private
    # @return [Array<String>]
    def implementation_descriptors
      desc = []
      desc << (name = @implementation.name)
      desc << (name && name.sub(/^(::)?#{@registry.interface}::/, ''))
      desc.compact.map(&:underscore).map(&:dasherize).reverse
    end
  end
end
