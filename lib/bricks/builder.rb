module Bricks
  class Builder
    def initialize(klass, &block)
      @class  = klass
      @object = klass.new
      @attrs  = {}

      instance_eval &block
    end

    def object(save = false)
      populate_object

      save_object if save

      @object
    end

    def trait(name, &block)
      (class << self; self; end).class_eval do
        define_method name do
          block.call

          self
        end
      end
    end

    def method_missing(name, *args, &block)
      attr = (return_object = name.to_s =~ /!$/) ? name.to_s.chop : name

      if respond_to?(attr)
        send(attr, *args)
      elsif settable?(attr)
        set attr, *args, &block
      else
        super
      end

      object if return_object
    end

    private

    def save_object
      @object.save!
    end

    def populate_object
      @attrs.each { |k, v|
        val = if Proc === v
                v.call
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

      @attrs[name] = val || block
    end
  end
end
