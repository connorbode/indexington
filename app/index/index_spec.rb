require_relative './index.rb'

describe 'index' do

  describe 'load_dictionary' do
    it 'loads a dictionary into memory' do
      index_path = File.expand_path "spec/fixtures/i0"
      i = Index.new index: index_path
      expect(i.dictionary).to eq({"afg" => "0", "against" => "8", "agenc" => "12"})
    end
  end
end