class Tokenizer

  @@number_regex = '[0-9]'

  # @options:
  # => preprocessing: an array of lambda preprocessing methods to call on a 
  #                    body of text before it is tokenized
  # => split: a regex pattern to split the body of text into tokens on
  # => token_processing: an array of lambda processing methods to call on
  #                       each token
  def initialize options = {}
    @options = options
  end

  # runs preprocessing rules on a body of input text
  # splits input text into tokens
  def tokenize input
    if @options[:preprocessing] then
      @options[:preprocessing].each { |method| input = method.call input }
    end
    r = if @options[:split] then Regexp.new @options[:split] else Regexp.new ' ' end
    return normalize_list input.split r
  end

  # normalizes a list of tokens
  def normalize_list tokens
    tokens.map! { |t| normalize t }
    tokens.compact!
    return tokens
  end

  # normalize a single token
  # runs a list of processing rules on a single list
  def normalize token
    if @options[:token_processing] then
      @options[:token_processing].each do |method|
        token = method.call(token)
      end
    end
    token = nil if token and token.empty?
    return token
  end
end