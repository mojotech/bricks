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
      @class = klass
      @object = klass.new

      instance_eval &block
    end

    def object(save = false)
      save_object if save

      @object
    end

    def method_missing(name, *args)
      if @object.respond_to?(name)
        @object.send "#{name}=", *args
      else
        super
      end
    end

    private

    def save_object
      @object.save!
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
