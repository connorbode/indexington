require 'nokogiri'
require 'pry-debugger'

class Index

  # starts the indexer on the glob pattern
  def initialize glob
    filenames = Dir[glob]
    filenames.each { |filename| parse_file filename }
    raise "No files found" if filenames.length < 1
  end

  # loads the file & parses
  def parse_file filename
    file = File.read(filename)
    doc = Nokogiri::XML::DocumentFragment.parse(file)
    doc.children().each { |article| parse_article article }
  end

  # parses a single article
  def parse_article article
    title = article.css('TITLE')
    puts title.text if title.length > 0
  end
end