require 'date'

class Article
  attr_accessor :author, :title, :body, :deferred, :language, :newspaper

  def initialize
    @saved = false
  end

  def save!
    @saved = true
  end

  def new_record?
    ! @saved
  end

  def saved?
    @saved
  end
end

class PrintMedium
  attr_accessor :start_date
end

class Magazine < PrintMedium
end

class Newspaper
  attr_accessor :name
end

