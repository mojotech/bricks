module Bricks
  module DSL
    def build(klass)
      builder(klass).dup_as_builder
    end

    def build!(klass)
      build(klass).generate
    end

    def create(klass)
      builder(klass).dup_as_creator
    end

    def create!(klass)
      create(klass).generate
    end

    def builder(klass)
      Bricks.builders[klass]
    end
  end
end
