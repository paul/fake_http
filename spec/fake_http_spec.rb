require "spec_helper"

RSpec.describe FakeHTTP do
  it "should work" do
    http = FakeHTTP.new do
      get "/posts/:id" do |params, options|
        {
          id: params["id"].to_i
        }
      end
    end

    response = http.get("/posts/1")
    expect(response).to be_a(HTTP::Response)
    expect(response.parse["id"]).to eq 1
  end
end

