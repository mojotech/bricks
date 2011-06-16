module Bricks
  module DSL
    def build(klass)
      builder(klass, false)
    end

    def build!(klass)
      build(klass).generate
    end

    def create(klass)
      builder(klass, true)
    end

    def create!(klass)
      create(klass).generate
    end

    def builder(klass, save)
      Bricks.builders[klass].derive(save)
    end
  end
end
