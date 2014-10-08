require 'nokogiri'
require 'objspace'
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

class Index

  # initializes the indexer on the supplied directory
  def initialize index_dir, options
    @options = options
    @tokenizer = Tokenizer.new @options[:tokenizer]
    @dictionary = {}
    @dumps = 0
  end

  # loads the file & parses
  def parse file
    doc = if @options[:fragment] then Nokogiri::XML::DocumentFragment.parse(file) else Nokogiri::XML::Document.parse(file) end
    doc.children().each do |article| 
      if article.kind_of? Nokogiri::XML::Element then
        parse_article article
        write_article article if @options[:write][:postings]
        @doc_id += 1
      end
    end
  end

  # parses a single article
  def parse_article article
    @options[:elements].each do |elem_desc|
      usage = ObjectSpace.memsize_of_all
      puts "Estimating memory usage as #{usage} bytes"
      elem = article.css(elem_desc[:tag])
      tokens = @tokenizer.tokenize elem.text
      tokens.each.with_index(1) do |token, index|
        @dictionary[token] = PostingsList.new if @dictionary[token].nil?
        @dictionary[token].add elem.text, index
      end
    end
  end

  # dumps the dictionary to a file
  def dump_dictionary file
    open file, 'w' do |f|
      Hash[@dictionary.sort].map do |key, value|
        f.puts "#{key}\n"
      end
    end
  end
end