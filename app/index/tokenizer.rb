require 'byebug'

# 
# Tokenizer.new {
#   :case_fold => true,
#   :ignore_numbers => true
# }
# 

class Tokenizer

  @@number_regex = '[0-9]'

  def initialize options = {}
    @options = options
  end

  # tokenize input
  def tokenize input
    normalize_list input.split ' '
  end

  # normalize the tokenized list
  def normalize_list tokens
    tokens.map! { |t| normalize t }
    tokens.compact!
    tokens
  end

  # normalize a single token
  def normalize token
    if @options[:case_fold] then token = token.downcase end
    if @options[:remove_numbers] and token.match @@number_regex then token = nil end
    if @options[:rules] then
      @options[:rules].each do |rule|

      end
    end
    token
  end
end