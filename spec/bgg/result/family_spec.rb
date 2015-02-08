require 'spec_helper'

describe Bgg::Result::Family do
  let(:item_xml) { Nokogiri.XML(xml_string) }
  let(:params) { {} }
  let(:xml_string) { '<items><item/></items>' }
  let(:request) { double('Bgg::Request::Family') }

  subject { Bgg::Result::Family.new(item_xml, request) }

  before do
    request.stub(:params).and_return(params)
  end

  context 'invalid item' do
    let (:xml_string) { '<items/>' }

    it 'throws an error' do
      expect{ Bgg::Result::Family.new(item_xml, request) }.to  raise_error ArgumentError
    end
  end

  context 'without data' do
    its(:description)    { should eq nil }
    its(:id)             { should eq nil }
    its(:image)          { should eq nil }
    its(:items)          { should eq [] }
    its(:name)           { should eq nil }
    its(:thumbnail)      { should eq nil }
    its(:type)           { should eq nil }
  end

  context 'with data' do
    let(:description)    { 'abc' }
    let(:id)             { 1234 }
    let(:image)          { 'def' }
    let(:item_id)        { 2 }
    let(:item_name)      { 'ghi' }
    let(:name)           { 'jkl' }
    let(:thumbnail)      { 'mno' }
    let(:type)           { 'pqr' }

    let(:params)         { { id: id } }
    let(:xml_string) {"<items>
                         <item type='#{type}'>
                           <thumbnail>#{thumbnail}</thumbnail>
                           <image>#{image}</image>
                           <name value='#{name}'/>
                           <description>#{description}</description>
                           <link id='#{item_id}' value='#{item_name}'/>
                         </item>
                       </items>"}

    its(:description)    { should eq description }
    its(:id)             { should eq id }
    its(:image)          { should eq image }
    its(:items)          { should eq [{ id: item_id, name: item_name }] }
    its(:name)           { should eq name }
    its(:thumbnail)      { should eq thumbnail }
    its(:type)           { should eq type }
  end
end
