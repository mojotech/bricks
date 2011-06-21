require File.expand_path(File.dirname(__FILE__) + '/spec_helper')

describe Bricks do
  include Bricks::DSL

  before :all do
    Bricks::Builder.adapter = Bricks::Adapters::ActiveRecord.new

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
        author   'Jack Jupiter'
        title    'a title'
        body     'the body'
        language 'Swahili'

        formatted_title { |obj| obj.title + " by " + obj.author }
        deferred { Time.now }
        newspaper.language { |_, article| article.language }

        %w(Socrates Plato Aristotle).each { |n| readers.name(n) }

        trait :in_english do
          language "English"
        end

        trait :by_jove do
          author "Jack Jupiter"
        end

        trait :maybe_bugle do
          ~newspaper.daily_bugle
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

  it "fetches an existing model instead of initializing it" do
    create(Newspaper).name!("The First in Line")

    create!(Newspaper).should == build?(Newspaper)
  end

  it "fetches an existing model instead of creating it" do
    create(Newspaper).name!("The First in Line")

    create!(Newspaper).should == create?(Newspaper)
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

    it "uses the object being built in deferred initialization" do
      build!(Article).formatted_title.should == "a title by Jack Jupiter"
    end

    it "fetches an existing model instead of creating it" do
      create!(Newspaper)

      n = create(Newspaper).name!("The Bugle Planet")

      create(Newspaper).name?("The Bugle Planet").should == n
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

    it "passes the parent into a deferred block" do
      build(Article).language!("Thai").newspaper.language.should == "Thai"
    end

    it "possibly looks for an existing record" do
      n = create(Newspaper).daily_bugle!
      a = create(Article).maybe_bugle!

      a.newspaper.should == n
    end

    it "possibly looks for an existing record (and finds none)" do
      a = create(Article).maybe_bugle!

      a.newspaper.should_not be_new_record
      a.newspaper.name.should == "The Daily Bugle"
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

    it "creates records with default attributes" do
      a = create(Article).tap { |b| 2.times { b.readers.build } }.generate

      a.should have(5).readers
    end
  end

  describe "builder inheritance" do
    it "uses the parent's builder if the model has none" do
      mag = build!(Magazine)

      mag.should be_a(Magazine)
      mag.start_date.should == Date.new(1900, 1, 1)
    end

    it "creates a builder for models that don't have one" do
      build!(Reader).should be_a(Reader)
    end
  end
end

