require 'nokogiri'
require 'objspace'
require 'byebug'
require_relative './tokenizer.rb'
require_relative './postings_list.rb'

class Indexer

  # initializes the indexer
  #
  # @options:
  # => fragment: true if the XML does not have a parent node
  # => tokenizer: options for the Tokenizer
  # => write:
  #    => postings: the folder to write separate postings to
  #    => tmp_folder: the folder to write temp indexes to
  # => elements: a list of XML tags to process
  # 
  # @doc_id: Used for the filename when saving indexed files as separate posts
  # @dump_ctr: Used for the filename when dumping temporary indexes
  def initialize options
    @options = options
    @tokenizer = Tokenizer.new @options[:tokenizer]
    @dictionary = {}
    @doc_id = 0
    @dump_ctr = 0
  end

  # parses a file
  # converts the file to XML object
  # iterates articles
  def parse file_contents
    begin
      file_contents.encode!('UTF-8', 'UTF-8', :invalid => :replace)
      doc = if @options[:fragment] then Nokogiri::XML::DocumentFragment.parse(file_contents) else Nokogiri::XML::Document.parse(file_contents) end
      doc.children().each do |article| 
        if article.kind_of? Nokogiri::XML::Element then
          parse_article article
          write_article article if @options[:write][:postings]
          @doc_id += 1
        end
      end
    rescue NoMemoryError
      dump
      parse file
    end
  end

  # processes the XML tags defined 
  # as important in the options
  def parse_article article
    begin
      @options[:elements].each do |elem|
        elem = article.css(elem[:tag])
        tokens = @tokenizer.tokenize elem.text
        tokens.each.with_index(1) { |token, index| parse_token token }
      end
    rescue NoMemoryError
      dump
      parse_article article
    end
  end

  # adds a post to a postings list
  # or creates a new postings list for a token
  def parse_token token
    begin
      if @dictionary[token].nil? then
        @dictionary[token] = PostingsList.new
      end
      @dictionary[token].add @doc_id
    rescue NoMemoryError
      dump
      parse_token token
    end
  end

  # writes a single article to disk
  def write_article article
    File.open (@options[:write][:postings] + @doc_id.to_s), 'w' do |f|
      article.write_xml_to f
    end
  end

  # dumps the index to a file
  def dump
    dict_file_name = @options[:write][:tmp_folder] + @dump_ctr.to_s + '.dict'
    postings_file_name = @options[:write][:tmp_folder] + @dump_ctr.to_s + '.post'
    puts "dumping tmp index #{@dump_ctr.to_s}"
    postings_file_head = 0
    File.open dict_file_name, 'w' do |dict_file|
      File.open postings_file_name, 'w' do |postings_file|
        Hash[@dictionary.sort].map do |term, postings|
          dict_file.print "#{term}:#{postings_file_head};"
          postings.list.each_with_index do |posting, index|
            s = posting.to_s
            postings_file.print s
            postings_file_head += s.length + 1
            if index == postings.list.size - 1 then 
              postings_file.print ";"
            else
              postings_file.print ","
            end
          end
        end
      end
    end
    @dump_ctr += 1
    @dictionary = {}
  end
end