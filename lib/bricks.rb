require 'bricks/builder'
require 'bricks/dsl'

module Bricks
  class << self
    attr_accessor :builders
  end

  class BuilderHashSet
    def initialize(&block)
      @builders = {}
    end

    def [](key)
      @builders[key]
    end

    def builder(klass, &block)
      @builders[klass] = Bricks::Builder.new(klass, &block)
    end
  end
end

def Bricks(&block)
  Bricks::builders = Bricks::BuilderHashSet.new

  Bricks::builders.instance_eval(&block)
end
