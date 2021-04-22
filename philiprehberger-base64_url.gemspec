# frozen_string_literal: true

require_relative 'lib/philiprehberger/base64_url/version'

Gem::Specification.new do |spec|
  spec.name          = 'philiprehberger-base64_url'
  spec.version       = Philiprehberger::Base64Url::VERSION
  spec.authors       = ['Philip Rehberger']
  spec.email         = ['me@philiprehberger.com']

  spec.summary       = 'URL-safe Base64 encoding with optional padding and JSON helpers'
  spec.description   = 'URL-safe Base64 encoding and decoding using Base64.urlsafe_encode64/decode64 ' \
                       'with no padding by default and convenience methods for JSON round-tripping.'
  spec.homepage      = 'https://philiprehberger.com/open-source-packages/ruby/philiprehberger-base64_url'
  spec.license       = 'MIT'

  spec.required_ruby_version = '>= 3.1.0'

  spec.metadata['homepage_uri']          = spec.homepage
  spec.metadata['source_code_uri']       = 'https://github.com/philiprehberger/rb-base64-url'
  spec.metadata['changelog_uri']         = 'https://github.com/philiprehberger/rb-base64-url/blob/main/CHANGELOG.md'
  spec.metadata['bug_tracker_uri']       = 'https://github.com/philiprehberger/rb-base64-url/issues'
  spec.metadata['rubygems_mfa_required'] = 'true'

  spec.files = Dir['lib/**/*.rb', 'LICENSE', 'README.md', 'CHANGELOG.md']
  spec.require_paths = ['lib']
end
