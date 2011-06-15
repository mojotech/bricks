require File.expand_path(File.dirname(__FILE__) + '/spec_helper')

describe Bricks do
  include Bricks::DSL

  before :all do
    Bricks do
      builder PrintMedium do
        start_date Date.new(1900, 1, 1)
      end

      builder Newspaper do
        name "The Daily Planet"

        trait :daily_bugle do
          name "The Daily Bugle"
        end
      end

      builder Article do
        author 'Jack Jupiter'
        title  'a title'
        body   'the body'
        deferred { Time.now }
        newspaper

        %w(Socrates Plato Aristotle).each { |n| readers.name(n) }

        trait :in_english do
          language "English"
        end

        trait :by_jove do
          author "Jack Jupiter"
        end

        trait :on_the_bugle do
          newspaper.daily_bugle
        end

        trait :with_alternative_readers do
          readers.clear

          %w(Tom Dick Harry).each { |n| readers.name(n) }
        end
      end
    end
  end

  after do
    Reader.delete_all
    Article.delete_all
    PrintMedium.delete_all
    Newspaper.delete_all
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

  describe "with traits" do
    it "returns the builder after calling the trait" do
      build(Article).in_english.should be_kind_of(Bricks::Builder)
    end

    it "#build returns the object if the trait is called with a bang" do
      a = build(Article).in_english!

      a.should be_kind_of(Article)
      a.should be_new_record
    end

    it "#create creates the object if the trait is called with a bang" do
      a = create(Article).in_english!

      a.should be_kind_of(Article)
      a.should be_saved
    end

    it "initializes the model fields" do
      build(Article).in_english!.language.should == "English"
    end

    it "combines multiple traits" do
      a = build(Article).in_english.by_jove!

      a.language.should == "English"
      a.author.should   == "Jack Jupiter"
    end
  end

  describe "with a many-to-one association" do
    it "initializes an association with the default values" do
      build!(Article).newspaper.name.should == 'The Daily Planet'
    end

    it "overrides the association" do
      build(Article).on_the_bugle!.newspaper.name.
        should == 'The Daily Bugle'
    end
  end

  describe "with a one-to-many association" do
    it "initializes an association with the default values" do
      build!(Article).readers.map { |r|
        r.name
      }.should == %w(Socrates Plato Aristotle)
    end

    it "overrides the association" do
      build(Article).with_alternative_readers!.readers.map { |r|
        r.name
      }.should == %w(Tom Dick Harry)
    end
  end

  describe "builder inheritance" do
    it "uses the parent's builder if the model has none" do
      mag = build!(Magazine)

      mag.should be_a(Magazine)
      mag.start_date.should == Date.new(1900, 1, 1)
    end
  end
end

