require 'bricks/dsl'

module Bricks
  class BuilderSet
    include Bricks::DSL

    def build(klass = @class)
      (@builders << super).last
    end

    def build!(klass = @class)
      (@builders << super).last
    end

    def clear
      @builders.clear
    end

    def create(klass = @class)
      (@builders << super).last
    end

    def create!(klass = @class)
      (@builders << super).last
    end

    def initialize(klass)
      @class    = klass
      @builders = []
    end

    def method_missing(name, *args)
      build(@class).send(name, *args)
    end

    def generate(parent = nil)
      @builders.map { |b| b.generate(parent) }
    end
  end
end
