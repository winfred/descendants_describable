require "descendants_describable/version"

module DescendantsDescribable
  extend ActiveSupport::Concern

  module ClassMethods

    #
    # Boots up your subclass descriptor DSL
    #
    # ex-
    #
    #   Activity.describe_descendants_with(Activities::Descriptors) do
    #     type :user_did_thing do             # see `#type` comment below for explanation
    #       actor_required                    # see `#method_missing` comment below for explanation
    #     end
    #   end
    #
    #
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


    #
    # Within your DSL, creates a new subclass (descendant) of the provided top level class.
    #
    # The method is named `type` because the primary use case right now is for setting an
    #   activities.type column for an Activity < ActiveRecord::Base Single-table Inheritance
    #   activity/event stream data model.
    #
    # Maybe there's a better, less-coupled-to-a-certain-use-case name for this...
    #  make a PR and pitch it if you think of it. :)
    #
    #
    # ex-
    #   type :user_did_thing # creates an empty `UserDidThing < Activity` class.
    #
    #
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

    #
    # By using method_missing, we can turn module names into snake_case descriptor methods
    # This is how you turn your descriptor modules into a DSL of your own
    # so you may declaratively add behaviors to your subclasses.
    #
    # It'll also catch class-level methods you define on your superclass and pass the args along.
    #
    # ex-
    #   Adding behavior & static descriptions of the sublcasses to be used when rendering an HTML
    #   page that serves as 'living documentation' for your application's event stream.
    #
    #   type :user_did_thing do
    #
    #     # example of including _behavior_, such as ActiveModel validations.
    #     # logically equivalent to `include Activities::Descriptors::ActorRequired` in subclass
    #     actor_required
    #
    #     # example of calling class method defined in superclass
    #     # logically equivalent to `description "whatever"` in subclass
    #     description 'Indicates the user has done a thing'
    #   end
    #
    # If you look closely, you can also use modules to apply 'grouping' to sets of activities
    #   such that the subclasses defined within that block all get the same top-level behavior
    #   (see `continue_module_tree`)
    #
    # You run the risk of adding too much complexity to your DSL usage if you have
    # too many levels like this though. Just look at the spec file and how many nested
    # ducky-things there are... It's technically supported but be highly skeptical of this feature.
    #
    def method_missing(method, *args, &block)
      if self.new_class.present?
        modify_class(args, method)
      else
        continue_module_tree(method, &block)
      end
    end

    def respond_to?(method)
      @description_module.const_get(method.to_s.camelize) rescue false
    end

    private

    def continue_module_tree(method)
      @common_modules << @description_module.const_get(method.to_s.camelize)
      yield if block_given?
      @common_modules.pop
    end

    def modify_class(args, method)
      if self.new_class.respond_to?(method)
        self.new_class.send(method, *args)
      else
        add_module @description_module.const_get(method.to_s.camelize)
      end
    end
  end
end
