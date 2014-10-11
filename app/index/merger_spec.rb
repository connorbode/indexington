require_relative './merger.rb'

describe 'Merger' do

  describe 'get_next_term' do
    it 'gets the next term properly' do
      i0 = File.expand_path 'spec/fixtures/i0.dict'
      d = { dictionary: File.open(i0) }
      m = Merger.new destination: i0, sources: []
      expect(m.get_next_term d).to eq({term: 'afg', post_ptr: '0'})
      expect(m.get_next_term d).to eq({term: 'against', post_ptr: '8'})
      expect(m.get_next_term d).to eq({term: 'agenc', post_ptr: '12'})
      expect(m.get_next_term d).to eq(nil)
    end
  end

  describe 'get_next_post' do
    it 'gets the next post' do
      i0 = File.expand_path 'spec/fixtures/i0.post'
      s = File.open i0
      m = Merger.new destination: i0, sources: []
      expect(m.get_next_post s).to eq({post: 12, last: false})
      expect(m.get_next_post s).to eq({post: 162, last: true})
      expect(m.get_next_post s).to eq({post: 155, last: true})
      expect(m.get_next_post s).to eq({post: 48, last: true})
    end
  end

  describe 'write_postings_list' do
    it 'merges two postings lists' do
      p0 = File.open(File.expand_path 'spec/fixtures/i0.post')
      p1 = File.open(File.expand_path 'spec/fixtures/i1.post')
      dest = File.open(File.expand_path('spec/fixtures/dest.post'), 'w')
      m = Merger.new destination: '', sources: []
      m.write_postings_list dest, [{postings_lists: p0}, {postings_lists: p1}]
      dest.close
      dest = File.open(File.expand_path('spec/fixtures/dest.post'))
      r = dest.read
      expect(r).to eq '12,162,194;'
    end

    it 'merges three postings lists' do
      p0 = File.open(File.expand_path 'spec/fixtures/i0.post')
      p1 = File.open(File.expand_path 'spec/fixtures/i1.post')
      p2 = File.open(File.expand_path 'spec/fixtures/i2.post')
      dest = File.open(File.expand_path('spec/fixtures/dest.post'), 'w')
      m = Merger.new destination: '', sources: []
      m.write_postings_list dest, [{postings_lists: p0}, {postings_lists: p1}, {postings_lists: p2}]
      dest.close
      dest = File.open(File.expand_path('spec/fixtures/dest.post'))
      r = dest.read
      expect(r).to eq '2,12,162,194,1002,10000;'
    end
  end

  # describe 'get_next_postings_list' do
  #   it 'gets the next postings list' do
  #     p0 = File.expand_path 'spec/fixtures/i0.post'
  #     i = { postings_lists: File.open(p0) }
  #     m = Merger.new destination: '', sources: []
  #     expect(m.get_next_postings_list i).to eq '12,162'
  #     expect(m.get_next_postings_list i).to eq '155'
  #     expect(m.get_next_postings_list i).to eq '48'
  #   end
  # end

  # describe 'merge' do
  #   it 'merges two files' do
  #     dest = File.expand_path 'spec/fixtures/dest'
  #     i0 = File.expand_path 'spec/fixtures/i0'
  #     i1 = File.expand_path 'spec/fixtures/i1'
  #     m = Merger.new destination: dest, sources: [i0, i1]
  #     m.merge
  #     d = File.open(dest + '.dict').read
  #     expect(d).to eq "afg:0;against:8;agenc:0,12;agricultur:4;ahead:8;"
  #   end
  # end
end