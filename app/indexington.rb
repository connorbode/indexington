require 'fast_stemmer'
require 'byebug'
require_relative('index/indexer.rb')
require_relative('index/merger.rb')

# builds the index
def build_index
  begin
    index = Indexer.new('', {
      :fragment => true,
      :elements => [
        { :tag => 'TITLE' }
      ],
      :tokenizer => {
        :preprocessing => [
          lambda { |input| return input.gsub /[\n-]/, ' ' }
        ],
        :split => '[ \/]',
        :token_processing => [
          lambda { |token| return token.downcase },
          lambda { |token| return token.gsub /[0-9\.,"()<>\';:\[\]{}]/, '' },
          lambda { |token| return token.stem }
        ]
      },
      :write => {
        :postings => "index/postings/",
        :tmp_folder => "index/tmp/i"
      }
    })

    filenames = Dir[ARGV[0]]
    raise "No files found" if filenames.length < 1

    filenames.each do |filename| 
      file = File.read filename 
      puts "parsing #{filename}"
      index.parse file 
    end 

    destination = File.expand_path "index/index"
    sources = Dir["index/tmp/*"].map!{|s| s[0..-6]}.uniq!.map!{|s| File.expand_path s}
    merger = Merger.new ({ destination: destination, sources: sources })
    puts "merging master index"
    merger.merge

  rescue Exception => e
    puts e.message
  end
end

build_index