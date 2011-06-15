require 'bricks/dsl'
require 'bricks/builder_set'

module Bricks
  class Builder
    include Bricks::DSL

    def self.adapter
      @@adapter
    end

    def self.adapter=(adapter)
      @@adapter = adapter
    end

    def ~@()
      @search = true

      self
    end

    def derive(klass = @class, save = @save)
      Builder.new(klass, @attrs, @traits, save)
    end

    def dup_as_builder
      derive(@class, false)
    end

    def dup_as_creator
      derive(@class, true)
    end

    def initialize(klass, attrs = nil, traits = nil, save = false, &block)
      @class  = klass
      @object = klass.new
      @attrs  = attrs ? deep_copy(attrs) : {}
      @traits = traits ? Module.new { include traits } : Module.new
      @save   = save

      extend @traits

      instance_eval &block if block_given?
    end

    def object
      populate_object

      @object = adapter.find(@class, @object) || @object if @search
      save_object                                        if @save

      @object
    end

    def trait(name, &block)
      @traits.class_eval do
        define_method "__#{name}", &block

        define_method name do |*args|
          send "__#{name}", *args

          self
        end
      end
    end

    def method_missing(name, *args, &block)
      attr = (return_object = name.to_s =~ /!$/) ? name.to_s.chop : name

      result = if respond_to?(attr)
                 send(attr, *args)
               elsif settable?(attr)
                 set attr, *args, &block
               else
                 super
               end

      if return_object
        object
      else
        result
      end
    end

    private

    def adapter
      Builder.adapter
    end

    def deep_copy(attrs)
      attrs.inject({}) { |a, (k, v)|
        a.tap { a[k] = Builder === v ? v.derive : v }
      }
    end

    def save_object
      @object.save!
    end

    def populate_object
      @attrs.each { |k, v|
        val = case v
              when Proc
                v.call
              when Builder, BuilderSet
                v.object
              else
                v
              end

        @object.send "#{k}=", val
      }
    end

    def settable?(name)
      @object.respond_to?("#{name}=")
    end

    def set(name, val = nil, &block)
      raise "Block and value given" if val && block_given?

      if block_given?
        @attrs[name] = block
      elsif val
        @attrs[name] = val
      elsif adapter.association?(@class, name, :one)
        @attrs[name] = create(adapter.association(@class, name).klass)
      elsif adapter.association?(@class, name, :many)
        @attrs[name] ||= BuilderSet.new(adapter.association(@class, name).klass)
      else
        raise "No value or block given and not an association: #{name}."
      end
    end
  end
end
