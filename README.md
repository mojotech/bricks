Bricks
======

Bricks is a hybrid Object Builder/Factory implementation. It aims to be a more flexible alternative to the existing Object Factory solutions while retaining as much simplicity as possible.

Usage
-----

Let's assume you have the following class:

    # Only ActiveRecord objects are supported right now.

    # == Schema Information
    #
    # Table name: articles
    #
    #  id              :integer(4)      not null, primary key
    #  title           :string(255)
    #  author          :string(255)
    #  formatted_title :string(510)
    #  publication_id  :integer(4)
    #
    class Article < ActiveRecord::Base
      belongs_to :publication
      has_many   :readers
    end

    # == Schema Information
    #
    # Table name: publications
    #
    #  id   :integer(4)      not null, primary key
    #  name :string(255)
    #  type :string(255)
    #
    class Publication < ActiveRecord::Base
    end

    class Newspaper < Publication
    end

    # == Schema Information
    #
    # Table name: publications
    #
    #  id         :integer(4)      not null, primary key
    #  name       :string(255)
    #  birth_date :date
    #
    class Reader < ActiveRecord::Base
    end

At its simplest, you can start using Bricks without declaring any builder (*note:* it gets less verbose).

    article_builder = build(Article)

This will give you a builder for the Article class, which you can then use to build an Article

    article_builder.
      title("Why I hate Guybrush Threepwood").
      author("Ghost Pirate LeChuck")

Contrary to the original pattern, builders are stateful (i.e., you don't get a new builder every time you call a method on the current builder).

You can get the underlying instance by calling _#generate_.

    article = article_builder.generate

This will initialize an Article with the attributes you passed the builder. If, instead of initializing, you'd prefer the record to be created right away, use _#create_ instead.

If you don't really care about the builder and just want the underlying instance you can instead use.

    article = build(Article).
      title("Why I hate Guybrush Threepwood").
      author!("Ghost Pirate LeChuck") # Note the "!"

When you want to use the default builder, without customizing it any further, you can tack the "!" at the end of the builder method:

    build!(Article)
    create!(Article)

### Building builders

Of course, using builders like described above isn't of much use. Let's create a builder for _Article_:

    Bricks do
      builder Article do
        title  "Why I hate Guybrush Threepwood"
        author "Ghost Pirate LeChuck"
      end
    end

You can then use it as you'd expect:

    # initializes an Article with default attributes set, and saves it
    article = create!(Article)

### Deferred initialization

    builder Article do
      # ...

      formatted_title { "The formatted title at #{Date.now}." }
    end

You can get at the underlying instance from deferred blocks:

    builder Article do
      # ...

      formatted_title { |obj| obj.title + " by " + obj.author }
    end

### Associations

Bricks supports setting association records.

#### Many-to-one (belongs to)

    Bricks do
      builder Publication do
        name "The Caribbean Times"
      end

      builder Article do
        # ...

        publication # instantiate a publication with the default attributes set
      end
    end

You can also customize the association builder instance:

    builder Article do
      # ...
      publication.name("The Caribeeaneer")
    end

If you prepend a "~" to the association declaration, the record will be initialized/created *only* if a record with the given attributes doesn't exist yet:

    builder Article do
      # ...
      ~publication # will search for a record with name "The Caribbean Times"
    end

#### One-to-many, Many-to-many (has many, has and belongs to many)

    Bricks do
      builder Article do
        # ...

        # readers association will have 3 records
        %w(Tom Dick Harry).each { |r| readers.name(r) }
      end
    end

Each call to the *-to-many association name will add a new builder, which you can then further customize:

    readers.name("Tom").birth_date(30.years.ago)

(Note that you don't use "!" here. That's only when building the records in your tests.)

### Builder Inheritance

Given the builder:

    builder Publication do
      name "The Caribbean Times"
    end

you can do something like:

    np = build!(Newspaper)
    np.name # => "The Caribbean Times"

### Traits

The real power of the Builder pattern comes from the use of traits. Instead of declaring name factories in a single-inheritance model, you instead declare traits, which you can then mix and match:

    builder Article
      # ...

      trait :alternative_publication do |name|
        publication.name(name)
      end

      trait :by_elaine do
        title  "Why I love Guybrush Threepwood"
        author "Elaine Marley-Threepwood"
      end
    end

Use it like this:

    build(Article).alternative_publication("The Caribeaneer").by_elaine

Note that if you want to override a *-to-many association inside a trait, you need to clear it first:

    builder Article
      # ...

      # this will reset the readers association
      trait :new_readers do
        readers.clear

        %(Charlotte Emily Anne).each { |r| readers.name(r) }
      end

      # this will add to the readers association
      trait :more_readers do
        readers.name("Groucho")
      end
    end

For an executable version of this documentation, please see spec/bricks_spec.rb.

Copyright
---------

Copyright (c) 2011 Mojo Tech. See LICENSE.txt for further details.
