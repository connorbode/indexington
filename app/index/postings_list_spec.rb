require_relative './postings_list.rb'

describe 'Postings List' do

  it 'should add a doc' do
    p = PostingsList.new 1
    p.add "Hello", 2
    expect(p.list.length).to eq 1
  end
end