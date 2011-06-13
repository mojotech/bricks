module Bricks
  class Builder
    def initialize(klass)
      @class = klass
      @object = klass.new
    end

    def object(save = false)
      save_object if save

      @object
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
    Builder.new(klass)
  end
end
