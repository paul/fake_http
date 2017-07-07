require "fake_http/identity"

require "http"

class FakeHTTP
  include HTTP::Chainable

  def initialize(&block)
    @builder = Builder.new
    @builder.instance_eval(&block)
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

    def request(*args)
      @builder.request(*args)
    end

    def branch(options)
      self.class.new(@options.merge(options), builder: @builder)
    end
  end

  class Builder

    def initialize
      @fakes = Hash.new { |h,k| h[k] = Array.new }
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

    def delete(pattern, &block)
      add_responder(:delete, pattern, &block)
    end

    def request(verb, uri, options = {})
      path = URI.parse(uri).path
      responder = @fakes[verb].detect { |responder| responder.match(path) }
      raise "No responder defined for #{verb} #{uri}" unless responder
      responder.call(uri, options)
    end

    private

    def add_responder(verb, pattern, &block)
      responder = Responder.new(pattern, block)
      @fakes[verb] << responder
    end

  end

  require "mustermann"
  class Responder
    def initialize(pattern, code)
      @pattern, @code = Mustermann.new(pattern), code
    end

    def match(uri)
      @pattern.match(uri)
    end

    def call(uri, options)
      params = @pattern.params(uri)
      status 200
      content_type "application/json"
      body = instance_exec(params, options, &@code)
      HTTP::Response.new(status: status, version: "1.1", headers: headers, body: body.to_json)
    end

    def status(new_status=nil)
      @status = new_status if new_status
      @status
    end

    def content_type(mime_type)
      headers["Content-Type"] = mime_type
    end

    def headers
      @headers ||= {}
    end
  end
end
