require File.expand_path(File.dirname(__FILE__) + '/spec_helper')

describe Bricks do
  include Bricks

  before :all do
    Bricks do
      plan Article do
        title 'a title'
        body  'the body'
        deferred { Time.now }
      end
    end
  end

  it "#build returns the constructor" do
    build(Article).should be_kind_of(Bricks::Builder)
  end

  it "#create returns the constructor" do
    create(Article).should be_kind_of(Bricks::Builder)
  end

  it "initializes a model" do
    a = build!(Article)

    a.should be_instance_of(Article)
    a.should be_new_record
  end

  it "creates a model" do
    a = create!(Article)

    a.should be_instance_of(Article)
    a.should be_saved
  end

  describe "with simple fields" do
    it "initializes model fields" do
      a = build!(Article)

      a.title.should == 'a title'
      a.body.should  == 'the body'
    end

    it "defers field initialization" do
      time = Time.now
      a    = build!(Article)

      a.deferred.should > time
    end
  end
end

