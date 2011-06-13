module Bricks
  class << self
    attr_accessor :plan
  end

  class Plan
    def initialize(&block)
      @plan = {}
      instance_eval &block
    end

    def [](key)
      @plan[key]
    end

    def plan(klass, &block)
      @plan[klass] = Builder.new(klass, &block)
    end
  end

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

  def build!(klass)
    builder(klass).object
  end

  def create!(klass)
    builder(klass).object(true)
  end

  def builder(klass)
    Bricks.plan[klass]
  end
end

def Bricks(&block)
  Bricks::plan = Bricks::Plan.new(&block)
end
