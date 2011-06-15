require File.expand_path(File.dirname(__FILE__) + '/../spec_helper')

describe Bricks::Builder do
  before :all do
    Bricks::Builder.adapter = Class.new {
      def association(*args)
        nil
      end

      alias_method :association?, :association
    }.new

    class Person
      attr_accessor :name
    end
  end

  it "fails if the model is missing the given attribute" do
    lambda {
      Bricks::Builder.new(Person).birth_date(Date.new(1978, 5, 3))
    }.should raise_error(Bricks::NoAttributeOrTrait)
  end

  it "forbids passing a block and an initial value" do
    lambda {
      Bricks::Builder.new(Person).name("Jack") { "heh" }
    }.should raise_error(Bricks::BadSyntax)
  end

  it "forbids passing no value or block to a non-association attribute" do
    lambda {
      Bricks::Builder.new(Person).name
    }.should raise_error(Bricks::BadSyntax)
  end
end
