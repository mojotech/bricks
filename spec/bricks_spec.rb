require File.expand_path(File.dirname(__FILE__) + '/spec_helper')

describe Bricks do
  include Bricks

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
end

