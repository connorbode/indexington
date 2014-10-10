require_relative './postings_list.rb'

describe 'Postings List' do

  it 'should add a doc' do
    p = PostingsList.new
    p.add "Hello"
    expect(p.list.length).to eq 1
  end
end