require 'fast_stemmer'
require 'sinatra'
require_relative('index/indexer.rb')
require_relative('index/merger.rb')
require_relative('index/index.rb')


# stop lists
$stop_30 = ['the', 'of', 'to', 'and', 'a', 'in', 'is', 'it', 'you', 'that', 'he', 'was', 'for', 'on', 'are', 'with', 'as', 'I', 'his', 'they', 'be', 'at', 'one', 'have', 'this', 'from', 'or', 'had', 'by', 'hot']
$stop_150 = ['the', 'of', 'to', 'and', 'a', 'in', 'is', 'it', 'you', 'that', 'he', 'was', 'for', 'on', 'are', 'with', 'as', 'I', 'his', 'they', 'be', 'at', 'one', 'have', 'this', 'from', 'or', 'had', 'by', 'hot', 'but', 'some', 'what', 'there', 'we', 'can', 'out', 'other', 'were', 'all', 'your', 'when', 'up', 'use', 'word', 'how', 'said', 'an', 'each', 'she', 'which', 'do', 'their', 'time', 'if', 'will', 'way', 'about', 'many', 'then', 'them', 'would', 'write', 'like', 'so', 'these', 'her', 'long', 'make', 'thing', 'see', 'him', 'two', 'has', 'look', 'more', 'day', 'could', 'go', 'come', 'did', 'my', 'sound', 'no', 'most', 'number', 'who', 'over', 'know', 'water', 'than', 'call', 'first', 'people', 'may', 'down', 'side', 'been', 'now', 'find', 'any', 'new', 'work', 'part', 'take', 'get', 'place', 'made', 'live', 'where', 'after', 'back', 'little', 'only', 'round', 'man', 'year', 'came', 'show', 'every', 'good', 'me', 'give', 'our', 'under', 'name', 'very', 'through', 'just', 'form', 'much', 'great', 'think', 'say', 'help', 'low', 'line', 'before', 'turn', 'cause', 'same', 'mean', 'differ', 'move', 'right', 'boy', 'old', 'too', 'does', 'tell']

# options for the indexer & merger
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
      lambda { |token| return token.gsub /[\.,"()<>\';:\[\]{}+$\*_=~]/, ''},  # remove garbage
      lambda { |token| return token.gsub /[0-9]/, '' },                       # remove numbers
      lambda { |token| return token.downcase },                               # case folding
     # lambda { |token| return $stop_30.include?(token) ? nil : token }        # 30 stop words
      lambda { |token| return $stop_150.include?(token) ? '' : token },       # 150 stop words
      lambda { |token| return token.stem }                                    # stemming
    ]
  },
  :write => {
    :postings => "index/postings/",
    :tmp_folder => "index/tmp/i"
  },
  :index => 'index/index'
}

indexer = Indexer.new($options)

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
index = Index.new $options

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