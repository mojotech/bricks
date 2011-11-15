require 'active_support/core_ext/class/attribute_accessors'
require 'active_support/core_ext/module/delegation'
require 'benchmark'
require 'bricks/adapters/active_record'

ActiveRecord::Base.establish_connection(
  :adapter => "sqlite3",
  :database => ":memory:"
 )

ActiveRecord::Migration.verbose = false

ActiveRecord::Schema.define(:version => 20110608204150) do
  create_table "articles", :force => true do |t|
    t.string   "author"
    t.string   "body"
    t.datetime "deferred"
    t.string   "formatted_title"
    t.string   "language"
    t.integer  "newspaper_id"
    t.string   "title"
    t.integer  "popularity"
    t.boolean  "active"
  end

  create_table "newspapers", :force => true do |t|
    t.string   "language"
    t.string   "name"
  end

  create_table "print_media", :force => true do |t|
    t.date     "start_date"
    t.string   "type"
  end

  create_table "readers", :force => true do |t|
    t.integer  "article_id"
    t.string   "name"
  end
end

class Article < ActiveRecord::Base
  belongs_to :newspaper
  has_many   :readers

  def saved?
    ! new_record?
  end
end

class PrintMedium < ActiveRecord::Base; end

class Magazine < PrintMedium; end

class Newspaper < ActiveRecord::Base; end

class Reader < ActiveRecord::Base; end
