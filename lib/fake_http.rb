# frozen_string_literal: true

require "ostruct"

require "http"
require "mustermann"
require "rack/utils"

# Acts like the HTTP gem, but doesn't make any real requests. Instead, you can
# manually stub them out:
#
# let(:http) do
#   FakeHTTP.new do
#     get "/foo" do
#       status 200
#       { foo: bar }
#     end
#   end
# end
#
# let(:client) { MyClient.new(http: http) }
#
class FakeHTTP
  include HTTP::Chainable

  def initialize(context = {}, &block)
    @builder = Builder.new
    @builder.instance_exec(OpenStruct.new(context), &block)
  end

  def merge(&block)
    @builder.instance_eval(&block)
  end

  def requests
    @builder.requests
  end

  def self.follow
    self
  end

  private

  def branch(options)
    Client.new(options, builder: @builder)
  end

  class Client
    include HTTP::Chainable

    def initialize(options, builder:)
      @options, @builder = options, builder
    end

    def request(verb, uri, options = {})
      @builder.request(verb, uri, @options.merge(options))
    end

    def branch(options)
      self.class.new(@options.merge(options), builder: @builder)
    end
  end

  class Builder
    def initialize
      @fakes = Hash.new { |h, k| h[k] = [] }
    end

    def get(pattern, &block)
      add_responder(:get, pattern, &block)
    end

    def post(pattern, &block)
      add_responder(:post, pattern, &block)
    end

    def put(pattern, &block)
      add_responder(:put, pattern, &block)
    end

    def patch(pattern, &block)
      add_responder(:patch, pattern, &block)
    end

    def delete(pattern, &block)
      add_responder(:delete, pattern, &block)
    end

    def request(verb, url, options = {})
      uri = URI.parse(url.to_s)
      path = uri.path
      query = Rack::Utils.default_query_parser.parse_nested_query(uri.query)

      responder = @fakes[verb].detect { |matcher| matcher.match(path) }
      unless responder
        raise <<~STR
          No path detected or match for #{verb} #{uri} in the list of defined paths

          responders - #{@fakes}
        STR
      end

      requests[path][verb] << options
      responder.call(path, query, options)
    end

    # { :get => { "/foo/bar" => [ { request 1 options }, { request 2 options }, ... ] } }
    def requests
      @requests ||= Hash.new { |h, k| h[k] = Hash.new { |h, k| h[k] = [] } }
    end

    private

    def add_responder(verb, pattern, &block)
      responder = Responder.new(pattern, block)
      @fakes[verb].unshift(responder)
    end
  end

  class Responder
    DEFAULT_STATUS = 200
    DEFAULT_CONTENT_TYPE = "application/json"
    def initialize(pattern, code)
      @pattern = Mustermann.new(pattern)
      @code = code
    end

    def match(uri)
      @pattern.match(uri)
    end

    def call(path, query_params, options)
      params = @pattern.params(path).merge(query_params)
      status(DEFAULT_STATUS)
      content_type(DEFAULT_CONTENT_TYPE)
      result = instance_exec(params, options, &@code)
      body = result.is_a?(Hash) ? result.to_json : result.to_s

      HTTP::Response.new(status: status, version: "1.1", headers: headers, body: body)
    end

    def status(new_status = nil)
      @status = new_status if new_status
      @status
    end

    def content_type(mime_type = nil)
      headers["Content-Type"] = mime_type if mime_type
      headers["Content-Type"]
    end

    def headers
      @headers ||= {}
    end
  end
end
