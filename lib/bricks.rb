require 'bricks/builder'
require 'bricks/dsl'

module Bricks
  class << self
    attr_accessor :plan
  end

  class Plan
    def initialize(&block)
      @plan = {}
    end

    def [](key)
      @plan[key]
    end

    def plan(klass, &block)
      @plan[klass] = Bricks::Builder.new(klass, &block)
    end
  end
end

def Bricks(&block)
  Bricks::plan = Bricks::Plan.new

  Bricks::plan.instance_eval(&block)
end
