require_relative './tokenizer.rb'
require 'byebug'

class Index

  attr_accessor :dictionary

  def initialize options
    @options = options
    @dictionary = load_dictionary
    @postings_lists = open_postings_lists
    @tokenizer = Tokenizer.new @options[:tokenizer]
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
    dict.close
    return dictionary
  end

  # opens the postings list file
  def open_postings_lists
    return File.open(@options[:index] + '.post')
  end

  # retrieves the postings list from a given position
  def get_postings_list position
    @postings_lists.seek position
    list = []
    loop do
      post = ""
      char = ""
      loop do
        char = @postings_lists.gets 1
        break if char == "," or char == ";"
        post << char
      end 
      list << post.to_i
      break if char == ";"
    end
    return list
  end

  # performs a query
  def query q
    terms = @tokenizer.tokenize q
    puts "searching for #{terms}"
    postings = []
    started = false
    terms.each do |term|
      post_pointer = @dictionary[term]
      if not post_pointer.nil? then 
        if postings.empty? then
          postings = get_postings_list(post_pointer.to_i) if not started
        else
          postings = postings & get_postings_list(post_pointer.to_i)
        end
      end
      started = true
    end
    return postings.sort.uniq
  end
end