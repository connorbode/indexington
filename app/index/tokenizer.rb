require 'byebug'

# 
# Tokenizer.new {
#   :split => regex to split on
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
    input = input.gsub /\\n/, ' ' if @options[:replace_newline] == true or @options[:replace_newline].nil?
    r = if @options[:split] then Regexp.new @options[:split] else Regexp.new ' ' end
    normalize_list input.split r
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
    token = nil if token.empty?
    token
  end
end