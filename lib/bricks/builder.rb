require 'bricks/dsl'

module Bricks
  class Builder
    include Bricks::DSL

    def derive(klass = @class, save = @save)
      Builder.new(klass, @attrs, @traits, save)
    end

    def dup_as_builder
      derive(@class, false)
    end

    def dup_as_creator
      derive(@class, true)
    end

    def initialize(klass, attrs = {}, traits = Module.new, save = false, &block)
      @class  = klass
      @object = klass.new
      @attrs  = attrs
      @traits = traits
      @save   = save

      extend @traits

      instance_eval &block if block_given?
    end

    def object
      populate_object

      save_object if @save

      @object
    end

    def trait(name, &block)
      @traits.class_eval do
        define_method name do
          block.call

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

    def save_object
      @object.save!
    end

    def populate_object
      @attrs.each { |k, v|
        val = case v
              when Proc
                v.call
              when Builder
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
      elsif association?(name)
        @attrs[name] = build(association(name).klass)
      else
        puts [@klass, name, val].inspect
        raise "No value or block given and not an association: #{name}."
      end
    end
  end
end
