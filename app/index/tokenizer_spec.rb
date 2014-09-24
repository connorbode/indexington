require_relative './tokenizer.rb'

describe 'Tokenizer' do 
  it "should tokenize a string" do
    t = Tokenizer.new
    tokens = t.tokenize 'this is a string'
    expect(tokens.length).to eq 4
    expect(tokens[0]).to eq 'this'
    expect(tokens[1]).to eq 'is'
    expect(tokens[2]).to eq 'a'
    expect(tokens[3]).to eq 'string'
  end

  it "should run token processing methods" do
    t = Tokenizer.new({
      :token_processing => [
        lambda{|token| return "#{token}test"}
      ]
    })
    token = t.normalize 'July'
    expect(token).to eq 'Julytest'
  end

  it "should run preprocessing methods" do
    t = Tokenizer.new({
      :preprocessing => [
        lambda { |input| return "this is new input!" }
      ]
    })
    tokens = t.tokenize 'does not really matter what this string is'
    expect(tokens.length).to eq 4
  end

  it "should split on spaces by default" do
    t = Tokenizer.new
    tokens = t.tokenize 'into the matrix'
    expect(tokens.length).to eq 3
  end

  it "should split on split option if passed" do
    t = Tokenizer.new split: '[,A]'
    tokens = t.tokenize 'secret,codeAstring'
    expect(tokens.length).to eq 3
    expect(tokens[0]).to eq 'secret'
    expect(tokens[1]).to eq 'code'
    expect(tokens[2]).to eq 'string'
  end
end