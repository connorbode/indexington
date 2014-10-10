require 'fast_stemmer'
require 'byebug'
require_relative('index/indexer.rb')

begin

  index = Indexer.new('', {
    :fragment => true,
    :elements => [
      { :tag => 'TITLE' }
    ],
    :tokenizer => {
      :case_fold => true,
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
      :index => "index/"
      :postings => "index/postings/",
      :dump => {
        :postings_prefix => "index/tmp/post",
        :dictionary_prefix => "index/tmp/dict"
      }
    }
  })

  filenames = Dir[ARGV[0]]
  raise "No files found" if filenames.length < 1

  filenames.each do |filename| 
    file = File.read filename 
    puts "parsing #{filename}"
    index.parse file 
  end 

rescue Exception => e
  puts e.message
end