
# used to merge indexes
#   
# options
# - dest_dir : the directory where the final index should be put

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
    postings_head = 0
    @sources.each { |source| source[:term] = get_next_term(source) }

    loop do
      @sources.sort_by! { |source| source[:term][:term] }
      postings_sources = [@sources[0]]
      i = 1
      loop do
        if not @sources[i].nil? and @sources[0][:term][:term] == @sources[i][:term][:term] then
          postings_sources << @sources[i]
          i += 1
        else
          break
        end
      end
      dict.print "#{@sources[0][:term][:term]}:#{postings_head};"
      postings_head += write_postings_list post, postings_sources

      lim = postings_sources.length
      i = 0
      while i < lim do
        @sources[i][:term] = get_next_term(@sources[i])
        if @sources[i][:term].nil? then
          @sources.delete_at i
          lim -= 1
        else
          i += 1
        end
      end
      break if @sources.empty?
    end

    dict.close
    post.close
  end

  # reads from postings lists in sources
  # writes merged postings list to post
  # returns number of characters written
  def write_postings_list post, sources
    postings_lists = sources.map { |source| { list: source[:postings_lists], more: true } }
    postings_lists.each { |list| list[:next_post] = get_next_post list[:list] }
    chars = 0
    last_post = nil
    loop do
      postings_lists.sort_by! { |list| list[:next_post][:post] }
      p = postings_lists[0][:next_post][:post].to_s
      chars += p.length + 1
      post.print p if p != last_post
      if postings_lists[0][:next_post][:last] then
        postings_lists.delete_at 0 
      else 
        postings_lists[0][:next_post] = get_next_post postings_lists[0][:list]
      end
      break if postings_lists.empty?
      post.print "," if p != last_post
      last_post = p
    end
    post.print ";"
    return chars
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

end