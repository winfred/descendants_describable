require "descendants_describable/version"

module DescendantsDescribable
  extend ActiveSupport::Concern

  module ClassMethods
    def describe_descendants_with(description_module, &block)
      descriptor = DescendantsDescriptor.new(self, description_module, block)
      descriptor.describe_descendants
      descriptor.register_reload_hook
      descriptor
    end
  end


  class DescendantsDescriptor

    attr_accessor :new_class

    def initialize(parent, description_module, description_proc = -> {})
      @common_modules = []
      @descendant_names = []
      @parent = parent
      @description_module = description_module
      @description_proc = description_proc
    end

    def describe_descendants
      instance_exec(&@description_proc)
    end

    def undefine_descendants
      @descendant_names.each do |descendant_name|
        Object.send(:remove_const, descendant_name) if Object.const_defined?(descendant_name)
      end
      @descendant_names = []
    end

    def reload_parent
      parent_name = @parent.name.to_sym
      Object.send(:remove_const, parent_name) if Object.const_defined?(parent_name)
      @parent = ActiveSupport::Dependencies.load_missing_constant(Object, parent_name)
    end

    def register_reload_hook
      descriptor = self
      ActiveSupport::Reloader.to_run do
        descriptor.undefine_descendants
        descriptor.reload_parent
        descriptor.describe_descendants
      end
    end

    def add_module(mod)
      self.new_class.send(:include, mod)
    end

    def type(name)

      self.new_class = begin
        Object.const_get(name.to_s.camelize)
      rescue NameError
        new_class = Class.new(@parent)
        Object.const_set(name.to_s.camelize, new_class)
        @descendant_names << name.to_s.camelize.to_sym
        new_class
      end

      @common_modules.each { |m| self.new_class.send(:include, m) } if @common_modules.any?

      yield if block_given?

      self.new_class = nil
    end

    def method_missing(method, *args)
      if self.new_class.present?
        add_module @description_module.const_get(method.to_s.camelize)
      else
        @common_modules << @description_module.const_get(method.to_s.camelize)
        yield if block_given?
        @common_modules.pop
      end
    end

    def respond_to?(method)
      @description_module.const_get(method.to_s.camelize) rescue false
    end
  end
end
