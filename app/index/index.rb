class Index

  attr_accessor :dictionary

  def initialize options
    @options = options
    @dictionary = load_dictionary
  end

  # loads the dictionary into memory
  def load_dictionary
    dict = File.open(@options[:index] + '.dict')
    dictionary = {}
    loop do
      term = ""
      position = ""
      char = ""
      loop do
        char = dict.gets 1
        break if char.nil? or char == ":"
        term << char
      end
      loop do
        char = dict.gets 1
        break if char.nil? or char == ";"
        position << char
      end
      break if char.nil?
      dictionary[term] = position
    end
    return dictionary
  end
end