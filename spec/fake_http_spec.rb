# frozen_string_literal: true

require "spec_helper"

RSpec.describe FakeHTTP do
  it "should work" do
    http = FakeHTTP.new do
      get "/posts/:id" do |params, _req_env|
        {
          id: params["id"].to_i
        }
      end
    end

    response = http.get("/posts/1")
    expect(response).to be_a(HTTP::Response)
    expect(response.parse["id"]).to eq 1
  end

  it "should record the requests" do
    http = FakeHTTP.new do
      get "/posts" do
        {}
      end
    end

    http.get("/posts")
    expect(http.requests["/posts"][:get]).to_not be_empty
  end

  describe "passing in context" do
    let(:user) { OpenStruct.new(id: 42, name: "Paul") }

    let(:fake_http) do
      FakeHTTP.new(user: user) do |context|
        get "/users/:id" do |params|
          if params["id"].to_i == context.user.id
            { name: context.user.name }
          else
            status 404
            {}
          end
        end
      end
    end

    it "should make the context available in the specs" do
      expect(fake_http.get("/users/42?foo=bar").status).to eq 200
      expect(fake_http.get("/users/42").parse).to match hash_including("name" => "Paul")

      expect(fake_http.get("/users/7").status).to eq 404
    end
  end
end
