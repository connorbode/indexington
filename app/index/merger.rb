
# used to merge indexes
#   
# options
# - dest_dir : the directory where the final index should be put

class Merger

  # initializes the merger
  def initialize options
    @options = options
  end

  # checks whether the destination index already exists
  # creates a new one if it does
  def check_destination
    if File.exists? @options[:destination] then
      random_number = rand(10000)
      @tmp = "#{@options[:destination]}.#{random_number}.tmp"
      FileUtils.copy_file @options[:destination], @tmp
    end
    return @tmp
  end

end