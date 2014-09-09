require_relative('./index.rb')

begin
  index = Index.new ARGV[0]
rescue Exception => e
  puts e.message
end