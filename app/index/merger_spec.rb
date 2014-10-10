require_relative './merger.rb'

describe 'Merger' do


  describe 'check_destination' do 
    it 'copies the destination to a new file if it exists' do
      dict0 = File.expand_path 'spec/fixtures/dict0'
      m = Merger.new destination: dict0
      tmp = m.check_destination
      expect(tmp.class.name).to eq "String"
      expect(File.exists? tmp).to eq true
      File.delete tmp
    end
  end
end