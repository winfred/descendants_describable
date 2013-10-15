require "descendants_describable/version"

module DescendantsDescribable
  extend ActiveSupport::Concern

  module ClassMethods
    def describe_descendants_with(description_module, &block)
      DescendantsDescriptor.new(self, description_module).instance_exec &block
    end
  end


  class DescendantsDescriptor

    attr_accessor :new_class

    def initialize(parent, description_module)
      @common_modules = []
      @parent = parent
      @description_module = description_module
    end

    def add_module(mod)
      self.new_class.send(:include, mod)
    end

    def type(name)
      self.new_class = Class.new(@parent)

      @common_modules.each { |m| self.new_class.send(:include, m) } if @common_modules.any?

      yield if block_given?

      Object.const_set(name.to_s.camelize, self.new_class)
      self.new_class = nil
    end

    def method_missing(method, *args)
      if self.new_class.present?
        add_module @description_module.const_get(method.to_s.camelize)
      else
        @common_modules << @description_module.const_get(method.to_s.camelize)
        yield if block_given?
        @common_modules.shift
      end
    end

    def respond_to?(method)
      @description_module.const_get(method.to_s.camelize) rescue false
    end
  end
end