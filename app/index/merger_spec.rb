require_relative './merger.rb'

describe 'Merger' do

  describe 'check_destination' do 
    it 'copies the destination to a new file if it exists' do
      dict0 = File.expand_path 'spec/fixtures/dict0'
      m = Merger.new destination: dict0, sources: []
      tmp = m.check_destination
      expect(tmp.class.name).to eq "String"
      expect(File.exists? tmp).to eq true
      File.delete tmp
    end
  end

  describe 'get_next_term' do
    it 'gets the next term properly' do
      dict0 = File.expand_path 'spec/fixtures/dict0'
      d = File.open dict0
      m = Merger.new destination: dict0, sources: []
      expect(m.get_next_term d).to eq({term: 'afg', doc_id: '0'})
      expect(m.get_next_term d).to eq({term: 'against', doc_id: '8'})
      expect(m.get_next_term d).to eq({term: 'agenc', doc_id: '12'})
      expect(m.get_next_term d).to eq(nil)
    end
  end
end