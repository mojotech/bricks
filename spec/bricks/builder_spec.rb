require File.expand_path(File.dirname(__FILE__) + '/../spec_helper')

describe Bricks::Builder do
  before :all do
    Bricks::Builder.adapter = Class.new do
      def association(*args)
        nil
      end

      alias_method :association?, :association
    end.new

    class Person
      attr_accessor :name, :first_name, :last_name
    end
  end

  it "fails if the model is missing the given attribute" do
    lambda do
      Bricks::Builder.new(Person).birth_date(Date.new(1978, 5, 3))
    end.should raise_error(Bricks::NoAttributeOrTrait)
  end

  it "forbids passing a block and an initial value" do
    lambda do
      Bricks::Builder.new(Person).name("Jack") { "heh" }
    end.should raise_error(Bricks::BadSyntax)
  end

  it "forbids passing no value or block to a non-association attribute" do
    lambda do
      Bricks::Builder.new(Person).name
    end.should raise_error(Bricks::BadSyntax)
  end

  it "always generates a new object" do
    b = Bricks::Builder.new(Person)

    b.generate.object_id.should_not == b.generate.object_id
  end

  describe "attribute evaluation ordering" do
    before :all do
    end

    it "doesn't care which order the attributes are declared" do
      b = Bricks::Builder.new Person do
        name { |obj| obj.first_name + " " + obj.last_name }
        first_name { "Jack" }
        last_name { "Black" }
      end

      b.derive.generate.name.should == "Jack Black"
    end
  end
end
