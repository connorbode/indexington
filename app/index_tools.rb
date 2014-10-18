#
# These tools are used to calculate the number of unique terms 
# in a dictionary and the number of postings in a postings lists file
# 


if not ARGV[0] then
  puts ""
  puts "-----------------------TOOOLZZZ---------------------"
  puts "Usage: 'ruby index_tools.rb {INDEX}'"
  puts "-----------------------TOOOLZZZ---------------------"
  puts ""

else

  index_path = File.expand_path(ARGV[0])
  dict = File.open(index_path + ".dict")
  post = File.open(index_path + ".post")

  # count terms
  terms = 0
  loop do
    char = dict.gets 1
    break if char.nil?
    terms += 1 if char == ";"
  end

  # count postings
  postings = 0
  loop do
    char = post.gets 1
    break if char.nil?
    postings += 1 if char == ";" or char == ","
  end

  puts "Dictionary contains #{terms} unique terms"
  puts "Postings file contains #{postings} postings"
end