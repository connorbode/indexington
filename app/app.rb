require_relative('./index.rb')

begin
  index = Index.new(ARGV[0], {
    :fragment => true,
    :elements => [
      { :tag => 'TITLE' }
    ]
  })
rescue Exception => e
  puts e.message
end