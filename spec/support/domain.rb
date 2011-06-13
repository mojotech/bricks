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

class Newspaper
  attr_accessor :name
end
