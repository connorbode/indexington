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
    @doc_ctr = 0
    @token_ctr = 0
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
          length = parse_article article
          write_article article, length if @options[:write][:postings]
          @doc_id += 1
          @doc_ctr += 1
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
        return tokens.length
      end
    rescue NoMemoryError
      dump
      return parse_article article
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
      @token_ctr += 1
    rescue NoMemoryError
      dump
      parse_token token
    end
  end

  # writes a single article to disk
  def write_article article, length
    File.open (@options[:write][:postings] + @doc_id.to_s), 'w' do |f|
      f.puts length
      article.write_xml_to f
    end
  end

  # dumps the index to a file
  def dump
    dict_file_name = @options[:write][:tmp_folder] + @dump_ctr.to_s + '.dict'
    postings_file_name = @options[:write][:tmp_folder] + @dump_ctr.to_s + '.post'
    meta_file_name = @options[:write][:tmp_folder] + @dump_ctr.to_s + '.meta'
    puts "dumping tmp index #{@dump_ctr.to_s}"
    postings_file_head = 0
    File.open dict_file_name, 'w' do |dict_file|
      File.open postings_file_name, 'w' do |postings_file|
        Hash[@dictionary.sort].map do |term, postings|
          dict_file.print "#{term}:#{postings_file_head}:"
          p_ctr = 0
          postings.list.each_with_index do |(posting, count), index|
            s = posting.to_s
            c = count.to_s
            postings_file.print "#{s}:#{count}"
            postings_file_head += s.length + c.length + 2
            if index == postings.list.size - 1 then 
              postings_file.print ";"
            else
              postings_file.print ","
            end
            p_ctr += 1
          end
          dict_file.print "#{p_ctr};"
        end
      end
    end
    File.open meta_file_name, 'w' do |meta_file|
      meta_file.puts @doc_ctr
      meta_file.puts @token_ctr
    end
    @doc_ctr = 0
    @token_ctr = 0
    @dump_ctr += 1
    @dictionary = {}
  end
end