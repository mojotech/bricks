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

    def after(hook, &block)
      @traits.class_eval do
        define_method "__after_#{hook}", &block
      end
    end

    def derive(args = {})
      build_attrs

      klass  = args[:class] || @class
      save   = args.has_key?(:save) ? args[:save] : @save
      search = args.has_key?(:search) ? args[:search] : @search

      Builder.new(klass, @attrs, @traits, save, search).tap { |b|
        b.run_hook :after, :clone if ! args[:class]
      }
    end

    def initialize(
        klass,
        attrs  = nil,
        traits = nil,
        save   = false,
        search = false,
        &block)
      @class  = klass
      @attrs  = attrs ? deep_copy(attrs) : []
      @traits = traits ? Module.new { include traits } : Module.new
      @save   = save
      @search = search
      @block  = block

      extend @traits
    end

    def generate(opts = {})
      parent = opts[:parent]
      search = opts.has_key?(:search) ? opts[:search] : @search
      obj    = initialize_object(parent)

      obj  = adapter.find(@class, Hash[*@attrs.flatten]) || obj if search
      save_object(obj)                                          if @save

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
      attr   = (return_object = name.to_s =~ /[!?]$/) ? name.to_s.chop : name
      result = if respond_to?(attr)
                 send(attr, *args)
               elsif settable?(attr)
                 set attr, *args, &block
               else
                 raise Bricks::NoAttributeOrTrait, "Can't find `#{name}'."
               end

      if return_object
        opts          = {:parent => @parent}
        opts[:search] = name.to_s =~ /\?$/ || @search

        generate opts
      else
        result
      end
    end

    protected

    def run_hook(position, name)
      full_name = "__#{position}_#{name}"

      send full_name if respond_to?(full_name)
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

    def initialize_object(parent)
      obj = @class.new

      @attrs.each { |(k, v)|
        val = case v
              when Proc
                v.call *[obj, parent].take([v.arity, 0].max)
              when Builder, BuilderSet
                v.generate(:parent => obj)
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

      nsym = name.to_sym
      pair = @attrs.assoc(nsym) || (@attrs << [nsym, nil]).last

      if block_given?
        pair[-1] = block

        self
      elsif val
        pair[-1] = val

        self
      elsif adapter.association?(@class, nsym, :one)
        pair[-1] = builder(adapter.association(@class, nsym).klass, @save)
      elsif adapter.association?(@class, nsym, :many)
        pair[-1] ||= BuilderSet.new(adapter.association(@class, nsym).klass)
      else
        raise Bricks::BadSyntax,
              "No value or block given and not an association: #{name}."
      end
    end

    def build_attrs
      instance_eval &@block if @block && @attrs.empty?
    end
  end
end
