# frozen_string_literal: true

module FakeHttp
  # Gem identity information.
  module Identity
    def self.name
      "fake_http"
    end

    def self.label
      "FakeHttp"
    end

    def self.version
      "0.1.0"
    end

    def self.version_label
      "#{label} #{version}"
    end
  end
end
