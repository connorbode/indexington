
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
      @sources.sort_by! { |source| [source[:term][:term], source[:term][:doc_id]] }
      i = 0
      current_term = @sources[0][:term][:term]
      dict.print "#{@sources[0][:term][:term]}:#{@sources[0][:term][:doc_id]}"
      @sources[0][:term] = get_next_term(@sources[0])
      @sources.delete_at 0 if @sources[0][:term].nil?
      loop do 
        if not @sources[i+1].nil? and current_term == @sources[i+1][:term][:term] then
          dict.print ",#{@sources[i+1][:term][:doc_id]}"
          @sources[i+1][:term] = get_next_term(@sources[i+1])
          if @sources[i+1][:term].nil? then
            @sources.delete_at (i+1)
          else
            i += 1
          end
        else
          break
        end
      end
      dict.print ";"
      break if @sources.length == 0
    end
    dict.close
  end

  # retrieves the next term from a source
  def get_next_term s
    term = ""
    doc_id = ""
    loop do
      char = s[:dictionary].gets 1
      return nil if char.nil?
      break if char == ":"
      term += char
    end
    loop do
      char = s[:dictionary].gets 1
      return nil if char.nil?
      break if char == ";"
      doc_id += char
    end
    return {term: term, doc_id: doc_id}
  end

end