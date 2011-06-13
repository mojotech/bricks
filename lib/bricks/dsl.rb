module Bricks
  module DSL
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
end
