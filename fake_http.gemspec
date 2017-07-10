# frozen_string_literal: true

$LOAD_PATH.push File.expand_path("../lib", __FILE__)
require "fake_http/identity"

Gem::Specification.new do |spec|
  spec.name = FakeHTTP::Identity.name
  spec.version = FakeHTTP::Identity.version
  spec.platform = Gem::Platform::RUBY
  spec.authors = ["Paul Sadauskas"]
  spec.email = ["psadauskas@gmail.com"]
  spec.homepage = ""
  spec.summary = ""
  spec.license = "MIT"

  if File.exist?(Gem.default_key_path) && File.exist?(Gem.default_cert_path)
    spec.signing_key = Gem.default_key_path
    spec.cert_chain = [Gem.default_cert_path]
  end

  spec.add_runtime_dependency "http", "~> 2"
  spec.add_runtime_dependency "mustermann"

  spec.add_development_dependency "rake", "~> 12.0"
  spec.add_development_dependency "gemsmith", "~> 8.2"
  spec.add_development_dependency "pry", "~> 0.10"
  spec.add_development_dependency "pry-byebug", "~> 3.4"
  spec.add_development_dependency "pry-state", "~> 0.1"
  spec.add_development_dependency "rspec", "~> 3.5"
  spec.add_development_dependency "guard-rspec", "~> 4.7"
  spec.add_development_dependency "reek", "~> 4.5"
  spec.add_development_dependency "rubocop", "~> 0.46"

  spec.files = Dir["lib/**/*"]
  spec.extra_rdoc_files = Dir["README*", "LICENSE*"]
  spec.require_paths = ["lib"]
end
