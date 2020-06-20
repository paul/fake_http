# FakeHttp

[![Gem Version](https://badge.fury.io/rb/fake_http.svg)](http://badge.fury.io/rb/fake_http)

# Features

[HTTP.rb](https://github.com/httprb/http) is one of the best Rubygems available
for writing custom API clients. Its simplicity and advanced feature-set make
for the most robust and reliable clients to use in your applications. One place
its lacking however, is the testing story.

Rather than relying on brittle tools like VCR or heavy-weight ones like
Webmock, FakeHTTP provides a simple Sintatra-like DSL that quacks like the
HTTP.rb gem, so you can easily inject responses you control into your client.

 * Stubs HTTP requests using [mustermann](http://sinatrarb.com/mustermann/),
   the same library providing Sinatra's DSL
 * Implements the same API as HTTP.rb (using the same HTTP::Chainable module)
 * Testing-framework agnostic

## Quick Example

```ruby

# my_client.rb
class MyClient

  # you're using Dependency-Injection for your client, right?
  def initialize(http: HTTP)
    @http = http
  end

  def create_blog(some, params)
    @http.post("https://acme.example/blogs", json: [some, params])
  end
end

# my_client_spec.rb
RSpec.describe MyClient do
  # Create the fake_http client
  let(:fake_http) do
    FakeHTTP.new do
      # Same DSL as Sinatra
      post "/blogs" do
        { some: "response" }
      end
    end
  end

  # Inject fake_http into your client instead of the real HTTP.rb
  let(:my_client) { MyClient.new(http: fake_http) }

  # Make requests as normal
  subject(:response) { my_client.create_blog("My Amazing Blog", "hello, world!") }

  # Get back a real HTTP::Response object to test
  it { should have_status_code(:ok) }

  # Including all the methods, like `#body.parse` to handle json
  specify { expect(response.body.parse).to be hash_including("some" => "response") }
end
```

# Setup

Add the following to your Gemfile:

    gem "fake_http"

# Usage

## Basic

Like the Sinatra DSL, the return value of the block becomes the response body.
By default, it assumes JSON and a status code of 200:

```ruby
http = FakeHTTP.new do
  get "/users" do
    [ { id: 42, name: "Paul" } ]
  end
end

resp = http.get("/users") # => #<HTTP::Response ...>
resp.status # => 200
resp.parse  # => [ { "id" => 42, "name" => "Paul" } ]
```

You can also add more patterns to match to an existing fake http instance with
`#merge`:

```ruby
http.merge do
  get "/users/:id" do
    { id: 42, name: "Paul" }
  end
end
```


## DSL methods

You can examine the parameters, both the ones extracted from the URL pattern
and the query params:

```ruby
http = FakeHTTP.new do
  get "/users/:id" do |params|
    if params["id"].to_i == 42
      { id: 42, name: "Paul" }
    else
      status 404
      headers["X-Custom-Header"] = "some value"
      { params: params }
    end
  end
end

resp = http.get("/users/42")    # => #<HTTP::Response ...>
resp.status                     # => 200
resp.parse                      # => [ { "id" => 42, "name" => "Paul" } ]

resp = http.get("/users/123?foo=bar")   # => #<HTTP::Response ...>
resp.status                     # => 404
resp.headers["X-Custom-Header"] # => "some value"
resp.parse                      # => [ { "id" => "123", "foo" => "bar" } ]
```

## Context

Since the responder block is executed in its own scope, it does not have access
to the context of your spec. You can, however, pass values to the initializer,
and they will be yielded to the block:

```ruby
let(:user) { create(:user) }
let(:http) do
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

specify { expect(http.get("/users/123").status).to eq 404
specify { expect(http.get("/users/#{user.id}").status).to eq 200
```

## Accessing requests made

You can access a Hash of all the requests that have been made to the fake http
instance with `#requests`:

```ruby
http = FakeHTTP.new do
  get "/posts" do
    {}
  end
end

http.get("/posts")
http.requests["/posts"][:get] #=> [#<HTTP::Options ...>]
```

# Tests

To test, run:

    bundle exec rake

# Versioning

Read [Semantic Versioning](http://semver.org) for details. Briefly, it means:

- Patch (x.y.Z) - Incremented for small, backwards compatible, bug fixes.
- Minor (x.Y.z) - Incremented for new, backwards compatible, public API enhancements/fixes.
- Major (X.y.z) - Incremented for any backwards incompatible public API changes.

# Code of Conduct

Please note that this project is released with a [CODE OF CONDUCT](CODE_OF_CONDUCT.md). By
participating in this project you agree to abide by its terms.

# Contributions

Read [CONTRIBUTING](CONTRIBUTING.md) for details.

# License

Copyright (c) 2020 [Paul Sadauskas](https://github.com/paul).
Read [LICENSE](LICENSE.md) for details.

# History

Read [CHANGES](CHANGES.md) for details.

# Credits

Developed by [Paul Sadauskas](https://github.com/paul)
