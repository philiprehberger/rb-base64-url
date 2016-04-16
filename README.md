# philiprehberger-base64_url

[![Tests](https://github.com/philiprehberger/rb-base64-url/actions/workflows/ci.yml/badge.svg)](https://github.com/philiprehberger/rb-base64-url/actions/workflows/ci.yml)
[![Gem Version](https://badge.fury.io/rb/philiprehberger-base64_url.svg)](https://rubygems.org/gems/philiprehberger-base64_url)
[![License](https://img.shields.io/github/license/philiprehberger/rb-base64-url)](LICENSE)

URL-safe Base64 encoding with optional padding and JSON helpers

## Requirements

- Ruby >= 3.1

## Installation

Add to your Gemfile:

```ruby
gem "philiprehberger-base64_url"
```

Or install directly:

```bash
gem install philiprehberger-base64_url
```

## Usage

```ruby
require 'philiprehberger/base64_url'

encoded = Philiprehberger::Base64Url.encode('hello world')
# => "aGVsbG8gd29ybGQ"

decoded = Philiprehberger::Base64Url.decode(encoded)
# => "hello world"
```

### JSON Helpers

```ruby
token = Philiprehberger::Base64Url.encode_json({ user_id: 42, role: 'admin' })
# => URL-safe Base64 string

payload = Philiprehberger::Base64Url.decode_json(token)
# => {"user_id"=>42, "role"=>"admin"}
```

## API

| Method | Description |
|--------|-------------|
| `.encode(data)` | Encode data to URL-safe Base64 without padding |
| `.decode(data)` | Decode a URL-safe Base64 string |
| `.encode_json(hash)` | Encode a hash as JSON then URL-safe Base64 |
| `.decode_json(str)` | Decode a URL-safe Base64 string and parse as JSON |

## Development

```bash
bundle install
bundle exec rspec
bundle exec rubocop
```

## License

MIT
