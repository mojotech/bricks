require File.expand_path(File.dirname(__FILE__) + '/../../spec_helper')

describe Bricks::Adapters::ActiveRecord do
  subject { Bricks::Adapters::ActiveRecord.new }

  it 'gracefully handles a missing association' do
    subject.association?(Reader, :birth_date, :one).should be_nil
  end

  it 'gracefully handles a missing association of the given type' do
    subject.association?(Article, :newspaper, :many).should be_nil
  end
end
