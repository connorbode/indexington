
# used to merge indexes
#   
# options
# - dest_dir : the directory where the final index should be put

class Merger

  # initializes the merger
  def initialize options
    @options = options
    @sources = @options[:sources].map { |source| File.open source }
  end

  # retrieves the next term from a source
  def get_next_term source
    term = ""
    doc_id = ""
    loop do
      char = source.gets 1
      return nil if char.nil?
      break if char == ":"
      term += char
    end
    loop do
      char = source.gets 1
      return nil if char.nil?
      break if char == ";"
      doc_id += char
    end
    return {term: term, doc_id: doc_id}
  end

  # checks whether the destination index already exists
  # creates a new one if it does
  def check_destination
    if File.exists? @options[:destination] then
      random_number = rand(10000)
      @tmp = "#{@options[:destination]}.#{random_number}.tmp"
      @sources.push { |source| File.open @tmp }
      FileUtils.copy_file @options[:destination], @tmp
    end
    return @tmp
  end

end