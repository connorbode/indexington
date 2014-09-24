class PostingsList

  attr_accessor :list

  # initializes an empty postings list
  def initialize
    @list = []
  end

  # adds an occurrence to a postings list
  def add document, position
    @list.push({
      :document => document,
      :position => position
    })
  end
end