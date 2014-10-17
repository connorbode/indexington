require 'nokogiri'
require 'objspace'
require 'byebug'
require_relative './tokenizer.rb'
require_relative './postings_list.rb'

# Smallest Working Example
# ========================
# Builds an index from all .xml files in the working
# directory.  Assumes that the XML documents do not
# have a parent node.
# 
# Parses
# 
#
# Index.new('*.xml', {
#   :fragment => true,
#   :elements => [
#     { :tag => 'title' }
#   ],
#   :tokenizer => # tokenizer options
# })

class Indexer

  # initializes the indexer on the supplied directory
  def initialize index_dir, options
    @options = options
    @tokenizer = Tokenizer.new @options[:tokenizer]
    @dictionary = {}
    @doc_id = 0
    @dump_ctr = 0
  end

  # loads the file & parses
  def parse file
    begin
      file.encode!('UTF-8', 'UTF-8', :invalid => :replace)
      doc = if @options[:fragment] then Nokogiri::XML::DocumentFragment.parse(file) else Nokogiri::XML::Document.parse(file) end
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

  # parses a single article
  def parse_article article
    begin
      @options[:elements].each do |elem_desc|
        elem = article.css(elem_desc[:tag])
        tokens = @tokenizer.tokenize elem.text
        tokens.each.with_index(1) { |token, index| parse_token token, index }
      end
    rescue NoMemoryError
      dump
      parse_article article
    end
  end

  # parses a single token
  def parse_token token, index
    begin
      if @dictionary[token].nil? then
        @dictionary[token] = PostingsList.new
      end
      @dictionary[token].add @doc_id
    rescue NoMemoryError
      dump
      parse_token token, index
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