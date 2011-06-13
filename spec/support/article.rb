class Article
  attr_accessor :title, :body

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
