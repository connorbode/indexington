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
    it 'returns an empty list if there are no results' do
      index_path = File.expand_path "spec/fixtures/i0"
      i = Index.new({:index => index_path, :tokenizer => {:split => '[ \/]'}})
      expect(i.query "afg against agenc").to eq []
    end

    it 'merges two lists appropriately' do
      index_path = File.expand_path "spec/fixtures/i6"
      i = Index.new({:index => index_path, :tokenizer => {:split => '[ \/]'}})
      expect(i.query "so tired").to eq [1,2]
    end
  end
end