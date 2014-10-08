
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
    if @options[:preprocessing] then
      @options[:preprocessing].each { |method| input = method.call input }
    end
    r = if @options[:split] then Regexp.new @options[:split] else Regexp.new ' ' end
    return normalize_list input.split r
  end

  # normalize the tokenized list
  def normalize_list tokens
    tokens.map! { |t| normalize t }
    tokens.compact!
    return tokens
  end

  # normalize a single token
  def normalize token
    if @options[:token_processing] then
      @options[:token_processing].each do |method|
        token = method.call(token)
      end
    end
    token = nil if token.empty?
    return token
  end
end