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

    def method_missing(name, *args, &block)
      if @object.respond_to?("#{name}=")
        raise "More than 1 argument: #{args.inspect}" if args.size > 1
        raise "Block and value given" if args.size > 0 && block_given?

        @attrs[name] = args.first || block
      else
        super
      end
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
  end
end
