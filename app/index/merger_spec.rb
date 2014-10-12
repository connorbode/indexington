require_relative './merger.rb'

describe 'Merger' do

  after(:all) do
    dest_dictionary = File.expand_path 'spec/fixtures/dest.dict'
    dest_postings_list = File.expand_path 'spec/fixtures/dest.post'
    File.delete(dest_dictionary)
    File.delete(dest_postings_list)
  end

  describe 'get_next_term' do
    it 'gets the next term properly' do
      i0 = File.expand_path 'spec/fixtures/i0.dict'
      d = { dictionary: File.open(i0) }
      m = Merger.new destination: i0, sources: []
      expect(m.get_next_term d).to eq({term: 'afg', post_ptr: '0'})
      expect(m.get_next_term d).to eq({term: 'against', post_ptr: '7'})
      expect(m.get_next_term d).to eq({term: 'agenc', post_ptr: '11'})
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
      num_written = m.write_postings_list dest, [{postings_lists: p0}, {postings_lists: p1}, {postings_lists: p2}]
      dest.close
      dest = File.open(File.expand_path('spec/fixtures/dest.post'))
      r = dest.read
      expect(num_written).to eq 24
      expect(r).to eq '2,12,162,194,1002,10000;'
    end

    it 'does not add duplicate posts' do
      p0 = File.open(File.expand_path 'spec/fixtures/i0.post')
      p3 = File.open(File.expand_path 'spec/fixtures/i3.post')
      p4 = File.open(File.expand_path 'spec/fixtures/i4.post')
      p5 = File.open(File.expand_path 'spec/fixtures/i5.post')
      dest = File.open(File.expand_path('spec/fixtures/dest.post'), 'w')
      m = Merger.new destination: '', sources: []
      num_written = m.write_postings_list dest, [{postings_lists: p0}, {postings_lists: p3}]
      dest.close
      dest = File.open(File.expand_path('spec/fixtures/dest.post'))
      r = dest.read
      expect(r).to eq '12,14,16,162;'
      expect(num_written).to eq 13
      dest.close
      dest = File.open(File.expand_path('spec/fixtures/dest.post'), 'w')
      num_written = m.write_postings_list dest, [{postings_lists: p4}, {postings_lists: p5}]
      dest.close
      dest = File.open(File.expand_path('spec/fixtures/dest.post'))
      r = dest.read
      expect(r).to eq '12;'
      expect(num_written).to eq 3
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
      p = File.open(dest + '.post').read
      expect(d).to eq "afg:0;against:7;agenc:11;agricultur:18;ahead:22;"
      expect(p).to eq "12,162;155;48,194;234;233;"
    end

    it 'merges three indexes' do
      dest = File.expand_path 'spec/fixtures/dest'
      i0 = File.expand_path 'spec/fixtures/i0'
      i1 = File.expand_path 'spec/fixtures/i1'
      i2 = File.expand_path 'spec/fixtures/i2'
      m = Merger.new destination: dest, sources: [i2, i1, i0]
      m.merge
      d = File.open(dest + '.dict').read
      p = File.open(dest + '.post').read
      expect(d).to eq "afg:0;against:7;agenc:11;agricultur:18;ahead:35;"
      expect(p).to eq "12,162;155;48,194;2,234,1002,10000;233;"
    end
  end
end