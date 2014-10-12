require_relative './index.rb'

describe 'index' do

  describe 'load_dictionary' do
    it 'loads a dictionary into memory' do
      index_path = File.expand_path "spec/fixtures/i0"
      i = Index.new index: index_path, tokenizer: {}
      expect(i.dictionary).to eq({"afg" => "0", "against" => "7", "agenc" => "11"})
    end
  end

  describe 'get_postings_list' do
    it 'loads a postings list' do
      index_path = File.expand_path "spec/fixtures/i0"
      i = Index.new index: index_path, tokenizer: {}
      expect(i.get_postings_list 7).to eq [155]
      expect(i.get_postings_list 0).to eq [12, 162]
      expect(i.get_postings_list 11).to eq [48]
    end
  end

  describe 'query' do
    it 'performs a query' do
      index_path = File.expand_path "spec/fixtures/i0"
      i = Index.new({:index => index_path, :tokenizer => {:split => '[ \/]'}})
      expect(i.query "afg against agenc").to eq [12,48,155,162]
    end
  end
end