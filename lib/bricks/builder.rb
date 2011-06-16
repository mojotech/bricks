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

    def self.instances
      @@instances ||= {}
    end

    def ~@()
      @search = true

      self
    end

    def derive(*args)
      klass, save = case args.size
                    when 2
                      args
                    when 1
                      case args.first
                      when Class
                        [args.first, @save]
                      else
                        [@class, args.first]
                      end
                    when 0
                      [@class, @save]
                    else
                      raise ArgumentError, "wrong number of arguments " +
                                              "(#{args.size} for 0, 1 or 2)"
                    end

      Builder.new(klass, @attrs, @traits, save)
    end

    def initialize(klass, attrs = nil, traits = nil, save = false, &block)
      @class  = klass
      @attrs  = attrs ? deep_copy(attrs) : []
      @traits = traits ? Module.new { include traits } : Module.new
      @save   = save

      extend @traits

      instance_eval &block if block_given?
    end

    def generate
      obj = initialize_object

      obj = adapter.find(@class, obj) || obj if @search
      save_object(obj)                       if @save

      obj
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
                 raise Bricks::NoAttributeOrTrait, "Can't find `#{name}'."
               end

      if return_object
        generate
      else
        result
      end
    end

    private

    def subject
      Builder.instances[@class] ||= @class.new
    end

    def adapter
      Builder.adapter
    end

    def deep_copy(attrs)
      attrs.inject([]) { |a, (k, v)|
        a.tap { a << [k, Builder === v ? v.derive : v] }
      }
    end

    def save_object(obj)
      obj.save!
    end

    def initialize_object
      obj = @class.new

      @attrs.each { |(k, v)|
        val = case v
              when Proc
                v.call *[obj].take([v.arity, 0].max)
              when Builder, BuilderSet
                v.generate
              else
                v
              end

        obj.send "#{k}=", val
      }

      obj
    end

    def settable?(name)
      subject.respond_to?("#{name}=")
    end

    def set(name, val = nil, &block)
      raise Bricks::BadSyntax, "Block and value given" if val && block_given?

      pair = @attrs.assoc(name) || (@attrs << [name, nil]).last

      if block_given?
        pair[-1] = block
      elsif val
        pair[-1] = val
      elsif adapter.association?(@class, name, :one)
        pair[-1] = builder(adapter.association(@class, name).klass, @save)
      elsif adapter.association?(@class, name, :many)
        pair[-1] ||= BuilderSet.new(adapter.association(@class, name).klass)
      else
        raise Bricks::BadSyntax,
              "No value or block given and not an association: #{name}."
      end
    end
  end
end
