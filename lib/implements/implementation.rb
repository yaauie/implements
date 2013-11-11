# encoding: utf-8

require 'active_support/inflector'

require_relative 'implementation/registry'

module Implements
  # Implementation: mix into your implementations
  module Implementation
    # An exception raised when an implementation cannot be found.
    NotFound = Class.new(NotImplementedError)

    private

    # @api public
    # @param iface [Module(Implements::Interface)]
    # @param options [Hash{Symbol => Object}] - ({}) optional options hash
    # @option options [Boolean] :auto - (true) whether to include this
    #   implementation in the interface's default search
    # @option options [String] :as - The canonical name for this
    #   implementation, must be unique across all implementations.
    # @option options [#to_s, Array<#to_s>] :groups - one or more named tags
    #   for this implementation, used for matching in Interface#implementation.
    #
    # If given, the block will be usde to determine the compatibility of this
    # interface with the arguments that would be passed to the implementation's
    # #initialize method.
    # @yieldparam (@see self#initialize)
    # @yieldreturn [Boolean]
    #
    # @return [void]
    # @raises [TypeError] unless iface is a Implements::Interface Module
    def implements(iface, options = {}, &block)
      unless iface.instance_of?(Module)  && iface.kind_of?(Interface)
        fail(TypeError, 'Argument must be a Implements::Interface Module')
      end

      params = {}
      params[:name] = options.fetch(:as) if options.key?(:as)
      groups = []
      groups << :default unless block_given?
      groups << :auto if options.fetch(:auto, true)
      params[:groups] = groups

      iface.register_implementation(self, params, &block)

      include iface
    end

    # @api private
    def self.extended(klass)
      unless klass.instance_of?(Class)
        fail(TypeError, "expected Class, got #{klass.class}")
      end
    end

    # @api private
    def self.included(base)
      base && fail(ScriptError, "#{self} supports only extend, not include.")
    end
  end
end
