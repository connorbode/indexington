require_relative './merger.rb'

describe 'Merger' do

  describe 'get_next_term' do
    it 'gets the next term properly' do
      i0 = File.expand_path 'spec/fixtures/i0.dict'
      d = { dictionary: File.open(i0) }
      m = Merger.new destination: i0, sources: []
      expect(m.get_next_term d).to eq({term: 'afg', doc_id: '0'})
      expect(m.get_next_term d).to eq({term: 'against', doc_id: '8'})
      expect(m.get_next_term d).to eq({term: 'agenc', doc_id: '12'})
      expect(m.get_next_term d).to eq(nil)
    end
  end

  describe 'merge' do
    it 'merges two files' do
      dest = File.expand_path 'spec/fixtures/dest'
      i0 = File.expand_path 'spec/fixtures/i0'
      i1 = File.expand_path 'spec/fixtures/i1'
      m = Merger.new destination: dest, sources: [i0, i1]
      m.merge
      d = File.open(dest + '.dict').read
      expect(d).to eq "afg:0;against:8;agenc:0,12;agricultur:4;ahead:8;"
    end
  end
end