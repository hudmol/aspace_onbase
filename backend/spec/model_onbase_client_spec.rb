require 'spec_helper'
require 'webmock/rspec'

describe 'Onbase Client model' do

  it "can upload a file and get it back" do

    stub_request(:post, "me:reallyme@onbase-dev.dartmouth.edu:443/api/OWMROBIInstance/api/documents/").
        to_return(:body => "999", :status => 200,
                  :headers => { 'Content-Length' => 3 })

    stub_request(:get, "me:reallyme@onbase-dev.dartmouth.edu:443/api/OWMROBIInstance/api/documents/999")

    opts = {}
    client = OnbaseClient.new(opts)

    up_file = File.new(__FILE__, 'r')
    keywords = "{'moo' => 'moo';}"
    docId = client.upload(up_file, keywords)

    docId.should eq("999")

    down_file = client.get(docId)
  end

end
