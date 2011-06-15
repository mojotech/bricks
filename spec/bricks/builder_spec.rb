require File.expand_path(File.dirname(__FILE__) + '/../spec_helper')

describe Bricks::Builder do
  before :all do
    class Person
      attr_accessor :name
    end
  end

  it "fails if the model is missing the given attribute" do
    lambda {
      Bricks::Builder.new(Person).birth_date(Date.new(1978, 5, 3))
    }.should raise_error(Bricks::NoAttributeOrTrait)
  end
end
