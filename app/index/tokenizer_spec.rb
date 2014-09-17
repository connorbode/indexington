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

  it "should not case fold by default" do
    t = Tokenizer.new
    tokens = t.tokenize 'THIS iS'
    expect(tokens[0]).to eq 'THIS'
    expect(tokens[1]).to eq 'iS'
  end

  it "should case fold" do
    t = Tokenizer.new case_fold: true
    tokens = t.tokenize 'THIS iS'
    expect(tokens[0]).to eq 'this'
    expect(tokens[1]).to eq 'is'
  end

  it "should tokenize numbers by default" do
    t = Tokenizer.new
    token = t.normalize '2014'
    expect(token).to eq '2014'
  end

  it "should remove numbers" do
    t = Tokenizer.new remove_numbers: true
    token = t.normalize '2014'
  end

  it "should run regex rules" do
    t = Tokenizer.new({
      :rules => {
        '.$' => ''
      }
    })
    token = t.normalize 'July,'
    expect(token).to eq 'July'
  end
end