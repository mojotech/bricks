require File.expand_path(File.dirname(__FILE__) + '/spec_helper')

describe Bricks do
  include Bricks::DSL

  before :all do
    # Dummy methods for associations
    Bricks::Builder.class_eval do
      def association?(name)
        [:newspaper].include?(name.to_sym)
      end

      def association(name)
        case name
        when :newspaper
          OpenStruct.new(:klass => Newspaper)
        else
          raise "Invalid name: #{name}."
        end
      end
    end

    Bricks do
      plan Newspaper do
        name "The Daily Planet"

        trait :daily_bugle do
          name "The Daily Bugle"
        end
      end

      plan Article do
        author 'Jack Jupiter'
        title  'a title'
        body   'the body'
        deferred { Time.now }
        newspaper

        trait :in_english do
          language "English"
        end

        trait :by_jove do
          author "Jack Jupiter"
        end

        trait :on_the_bugle do
          newspaper.daily_bugle
        end
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

  describe "with traits" do
    it "returns the builder after calling the trait" do
      build(Article).in_english.should be_kind_of(Bricks::Builder)
    end

    it "returns the object if the trait is called with a bang" do
      build(Article).in_english!.should be_kind_of(Article)
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
end

