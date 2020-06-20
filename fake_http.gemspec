# frozen_string_literal: true

$LOAD_PATH.push File.expand_path("lib", __dir__)
require "fake_http/version"

Gem::Specification.new do |spec|
  spec.name = "fake_http"
  spec.version = FakeHTTP::VERSION
  spec.platform = Gem::Platform::RUBY
  spec.authors = ["Paul Sadauskas"]
  spec.email = ["psadauskas@gmail.com"]

  spec.summary = "Provides a Sinatra-like DSL for faking HTTP.rb requests"
  spec.homepage = "https://github.com/paul/fake_http"

  spec.license = "MIT"

  if File.exist?(Gem.default_key_path) && File.exist?(Gem.default_cert_path)
    spec.signing_key = Gem.default_key_path
    spec.cert_chain = [Gem.default_cert_path]
  end

  spec.add_runtime_dependency "http", ">= 2"
  spec.add_runtime_dependency "mustermann"
  spec.add_runtime_dependency "rack"

  spec.add_development_dependency "guard-rspec", "~> 4.7"
  spec.add_development_dependency "pry", ">= 0.10"
  spec.add_development_dependency "rake", ">= 13"
  spec.add_development_dependency "reek", "~> 6.0"
  spec.add_development_dependency "rspec", "~> 3.5"
  spec.add_development_dependency "rubocop", "~> 0.85"

  spec.files = Dir["lib/**/*"]
  spec.extra_rdoc_files = Dir["README*", "LICENSE*"]
  spec.require_paths = ["lib"]
end
