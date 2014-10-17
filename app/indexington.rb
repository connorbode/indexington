require 'fast_stemmer'
require 'sinatra'
require_relative('index/indexer.rb')
require_relative('index/merger.rb')
require_relative('index/index.rb')


$options = {
  :fragment => true,
  :elements => [
    { :tag => 'BODY' },
    { :tag => 'TITLE' }
  ],
  :tokenizer => {
    :preprocessing => [
      lambda { |input| return input.gsub /[\n-]/, ' ' }
    ],
    :split => '[ \/]',
    :token_processing => [
      lambda { |token| return token.downcase },
      lambda { |token| return token.gsub /[0-9\.,"()<>\';:\[\]{}+$\*_=~]/, '' },
      lambda { |token| return token.stem }
    ]
  },
  :write => {
    :postings => "index/postings/",
    :tmp_folder => "index/tmp/i"
  },
  :index => 'index/index'
}

index = Index.new $options
indexer = Indexer.new('', $options)

# indexing process
if ARGV[0] then
  begin
    filenames = Dir[ARGV[0]]
    raise "No files found" if filenames.length < 1

    filenames.each do |filename| 
      file = File.read filename 
      puts "parsing #{filename}"
      indexer.parse file 
    end 

    indexer.dump

    destination = File.expand_path "index/index"
    sources = Dir["index/tmp/*"].map!{|s| s[0..-6]}.uniq!.map!{|s| File.expand_path s}
    merger = Merger.new ({ destination: destination, sources: sources })
    puts "merging master index"
    merger.merge

  rescue Exception => e
    puts e.message
  end
end

# run server
set :public_folder, File.expand_path('app/public/dist')

get '/query/:query' do
  results = index.query params[:query]
  xml_response = "<results>"
  limit = 10
  i = 0
  results.each do |result|
    xml_response << File.open('index/postings/' + result.to_s).read
    # break if i == limit
    # i += 1
  end
  xml_response << "</results>"
  xml_response
end

get '/' do
  File.read(File.join('app', 'public', 'dist', 'index.html'))
end