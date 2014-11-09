require_relative './tokenizer.rb'
require 'byebug'

class Index

  attr_accessor :dictionary

  def initialize options
    @options = options
    @dictionary = load_dictionary
    @index_meta = load_meta
    @postings_lists = open_postings_lists
    @tokenizer = Tokenizer.new @options[:tokenizer]
  end

  # loads meta-data into memory
  def load_meta
    meta = File.open(@options[:index] + '.meta')
    num_docs = meta.gets
    collection_length = meta.gets
    return {:number_of_documents => num_docs.to_i, :collection_length => collection_length.to_i}
  end

  # loads the dictionary into memory
  def load_dictionary
    dict = File.open(@options[:index] + '.dict')
    dictionary = {}
    loop do
      term = ""
      position = ""
      count = ""
      char = ""
      loop do
        char = dict.gets 1
        break if char.nil? or char == ":"
        term << char
      end
      loop do
        char = dict.gets 1
        break if char.nil? or char == ":"
        position << char
      end
      loop do
        char = dict.gets 1
        break if char.nil? or char == ";"
        count << char
      end
      break if char.nil?
      dictionary[term] = {:position => position.to_i, :count => count.to_i}
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
      puts "#{term} idf: #{idf term}"
      post_pointer = @dictionary[term][:position]
      if not post_pointer.nil? then 
        if postings.empty? then
          postings = get_postings_list(post_pointer) if not started
        else
          postings = postings & get_postings_list(post_pointer)
        end
      end
      started = true
    end
    return postings.sort.uniq
  end

  # generates idf for a term
  def idf term
    total_docs = @index_meta[:number_of_documents]
    document_frequency = @dictionary[term][:count]
    return 0 if document_frequency.nil?
    return Math.log10(total_docs / document_frequency)
  end
end