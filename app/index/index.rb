require 'nokogiri'

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
#   ]
# })

class Index

  @dictionary

  # starts the indexer on the glob pattern
  def initialize glob, options
    @options = options
    filenames = Dir[glob]
    filenames.each { |filename| parse_file filename }
    raise "No files found" if filenames.length < 1
  end

  # loads the file & parses
  def parse_file filename
    file = File.read(filename)
    doc = if @options[:fragment] then Nokogiri::XML::DocumentFragment.parse(file) else Nokogiri::XML::Document.parse(file) end
    doc.children().each { |article| parse_article article }
  end

  # parses a single article
  def parse_article article
    @options[:elements].each do |elem_desc|
      elem = article.css(elem_desc[:tag])
      elem.text
    end
  end
end