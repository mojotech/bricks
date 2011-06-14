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
      if @builders[key]
        @builders[key]
      elsif Class === key
        builder = self[key.superclass] and @builders[key] = builder.derive(key)
      end
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
