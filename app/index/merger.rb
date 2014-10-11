
# used to merge indexes
#   
# options
# - dest_dir : the directory where the final index should be put

require 'byebug'

class Merger

  # initializes the merger
  def initialize options
    @options = options
    @sources = @options[:sources].map do |source| 
      { dictionary: File.open(source + '.dict'),
        postings_lists: File.open(source + '.post') }
    end
  end

  # merges sources into destination
  # this algo is f*$%ed
  def merge
    dict = File.open @options[:destination] + '.dict', 'w'
    post = File.open @options[:destination] + '.post', 'w'
    @sources.each { |source| source[:term] = get_next_term(source) }

    loop do
      @sources.sort_by { |source| source[:term] }
      this_term = [@sources[0]]
      postings_list = get_next_postings_list @sources[0]
      dict.print @sources[]
    end

    dict.close
  end

  # reads from postings lists in sources
  # writes merged postings list to post
  # returns number of characters written
  def write_postings_list post, sources
    postings_lists = sources.map { |source| { list: source[:postings_lists], more: true } }
    # byebug
    postings_lists.each { |list| list[:next_post] = get_next_post list[:list] }

    loop do
      postings_lists.sort_by { |list| list[:next_post][:post] }
      post.print "#{postings_lists[0][:next_post][:post]}"
      if postings_lists[0][:next_post][:last] then
        postings_lists.delete_at 0 
      else 
        postings_lists[0][:next_post] = get_next_post postings_lists[0][:list]
      end
      break if postings_lists.empty?
      post.print ","
    end
    post.print ";"
  end

  # gets the next post from a postings list
  # sets a flag if it is the last
  def get_next_post source
    post = ""
    last = false
    loop do
      c = source.gets 1
      break if c == ","
      if c == ";" then
        last = true
        break
      end
      post << c
    end
    return { post: post.to_i, last: last }
  end

  # retrieves the next term from a source
  def get_next_term s
    term = ""
    post_ptr = ""
    loop do
      char = s[:dictionary].gets 1
      return nil if char.nil?
      break if char == ":"
      term << char
    end
    loop do
      char = s[:dictionary].gets 1
      return nil if char.nil?
      break if char == ";"
      post_ptr << char
    end
    return {term: term, post_ptr: post_ptr}
  end

  # # retrieves the next postings list from a source
  # def get_next_postings_list s
  #   list = []
  #   loop do
  #     char = s[:postings_lists].gets 1
  #     return nil if char.nil?
  #     break if char == ";"
  #     list << char
  #   end
  #   return list
  # end

end