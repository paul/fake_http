# frozen_string_literal: true

class FakeHTTP
  # Gem identity information.
  module Identity
    def self.name
      "fake_http"
    end

    def self.label
      "FakeHTTP"
    end

    def self.version
      "0.2.0"
    end

    def self.version_label
      "#{label} #{version}"
    end
  end
end
