require 'bricks/builder'

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
      @plan[klass] = Bricks::Builder.new(klass, &block)
    end
  end

  def build(klass)
    builder(klass)
  end

  def build!(klass)
    builder(klass).object
  end

  def create(klass)
    builder(klass)
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
