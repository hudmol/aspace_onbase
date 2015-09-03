require 'spec_helper'
require_relative 'factories'

describe 'Onbase Document model' do

  it "supports creating a record" do
    od_json = build(:json_onbase_document, :name => "Private business")
    onbase_doc = OnbaseDocument.create_from_json(od_json)
    OnbaseDocument[onbase_doc[:id]].name.should eq("Private business")
  end

end
