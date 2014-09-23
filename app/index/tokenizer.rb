require 'byebug'

# 
# Tokenizer.new {
#   :case_fold => true,
#   :methods => [ Procs or Lambdas]
#   :rules => { regex rule => regex replace}
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
    if @options[:rules] then
      @options[:rules].map do |rule, replace|
        regex = Regexp.new rule
        token.gsub! regex, replace
      end
    end
    if @options[:methods] then
      @options[:methods].each do |method|
        token = method.call(token)
      end
    end
    token
  end
end