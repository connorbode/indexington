class PostingsList

  attr_accessor :list

  # initializes an empty postings list
  def initialize
    @list = []
  end

  # adds an occurrence to a postings list
  def add document
    raise NoMemoryError if @list.length > 20 
    @list.push document if not @list.include? document
  end
end