class PostingsList

  attr_accessor :list

  # initializes an empty postings list
  def initialize
    @list = {}
  end

  # adds an occurrence to a postings list
  def add document
    raise NoMemoryError if @list.length > 20 
    if @list.has_key? document then
      @list[document] += 1
    else
      @list[document] = 1
    end
  end
end