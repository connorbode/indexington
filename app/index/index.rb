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
  def get_postings_list position, postings, term
    @postings_lists.seek position
    loop do
      post = ""
      term_frequency = ""
      char = ""
      loop do
        char = @postings_lists.gets 1
        break if char == ":"
        post << char
      end
      loop do
        char = @postings_lists.gets 1
        break if char == "," or char == ";"
        term_frequency << char
      end 
      if postings[post.to_i].nil? then
        postings[post.to_i] = { term => term_frequency.to_i }
      else 
        postings[post.to_i][term] = term_frequency.to_i
      end
      break if char == ";"
    end
  end

  # performs a query
  def query q
    terms = @tokenizer.tokenize q
    puts "searching for #{terms}"
    started = false
    postings = {}
    terms.each do |term|
      post_pointer = @dictionary[term][:position]
      if not post_pointer.nil? then 
        get_postings_list(post_pointer, postings, term)
      end
    end
    return bm25 postings
  end

  # runs bm25 on each posting
  def bm25 postings
    ranked = postings.map do |posting, terms|
      doc = File.open('index/postings/' + posting.to_s)
      document_length = doc.gets.to_i
      doc.close
      scores = terms.map { |term, term_frequency| bm25_score term, term_frequency, document_length }
      score = scores.reduce(:+)
      {:score => score, posting: posting}
    end
    return ranked.sort_by { |r| r[:score] }
  end

  # generates idf for a term
  def idf term
    total_docs = @index_meta[:number_of_documents]
    return 0 if @dictionary[term].nil?
    document_frequency = @dictionary[term][:count]
    return Math.log10(total_docs / document_frequency)
  end

  # generates the bm25 score for a term
  # in a document
  def bm25_score term, term_frequency, document_length
    k1 = @options[:bm25][:k1]
    b = @options[:bm25][:b]
    avg_document_length = @index_meta[:collection_length] / @index_meta[:number_of_documents]
    idf_score = idf term
    numerator = term_frequency * (k1 + 1)
    denominator = term_frequency + k1 * (1 - b + b * (document_length / avg_document_length))
    return idf_score * (numerator / denominator)
  end
end