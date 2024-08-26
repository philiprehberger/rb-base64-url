# philiprehberger-base64_url

[![Tests](https://github.com/philiprehberger/rb-base64-url/actions/workflows/ci.yml/badge.svg)](https://github.com/philiprehberger/rb-base64-url/actions/workflows/ci.yml)
[![Gem Version](https://badge.fury.io/rb/philiprehberger-base64_url.svg)](https://rubygems.org/gems/philiprehberger-base64_url)
[![Last updated](https://img.shields.io/github/last-commit/philiprehberger/rb-base64-url)](https://github.com/philiprehberger/rb-base64-url/commits/main)

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
require "philiprehberger/base64_url"

encoded = Philiprehberger::Base64Url.encode('hello world')
# => "aGVsbG8gd29ybGQ"

decoded = Philiprehberger::Base64Url.decode(encoded)
# => "hello world"
```

### Padding Control

```ruby
require "philiprehberger/base64_url"

Philiprehberger::Base64Url.encode("Hello")                  # => "SGVsbG8" (no padding)
Philiprehberger::Base64Url.encode("Hello", padding: true)    # => "SGVsbG8=" (with padding)
```

### Validation

```ruby
Philiprehberger::Base64Url.valid?("aGVsbG8")   # => true
Philiprehberger::Base64Url.valid?("!!!")        # => false
```

### JSON Helpers

```ruby
token = Philiprehberger::Base64Url.encode_json({ user_id: 42, role: 'admin' })
# => URL-safe Base64 string

payload = Philiprehberger::Base64Url.decode_json(token)
# => {"user_id"=>42, "role"=>"admin"}
```

### Constant-Time Comparison

```ruby
token_a = Philiprehberger::Base64Url.encode("secret")
token_b = params[:token]

Philiprehberger::Base64Url.secure_compare(token_a, token_b) # => true/false
```

### Decoded Size

```ruby
Philiprehberger::Base64Url.byte_length("aGVsbG8gd29ybGQ") # => 11
```

### File Helpers

```ruby
encoded = Philiprehberger::Base64Url.encode_file("image.png")
Philiprehberger::Base64Url.decode_to_file(encoded, "copy.png")
```

## API

| Method | Description |
|--------|-------------|
| `.encode(data, padding: false)` | Encode data to URL-safe Base64 (optional padding) |
| `.decode(data)` | Decode a URL-safe Base64 string |
| `.encode_json(hash)` | Encode a hash as JSON then URL-safe Base64 |
| `.decode_json(str)` | Decode a URL-safe Base64 string and parse as JSON |
| `.valid?(data)` | Check if a string is valid URL-safe Base64 |
| `.secure_compare(a, b)` | Constant-time comparison of two strings |
| `.byte_length(encoded)` | Calculate decoded byte count without decoding |
| `.encode_file(path, padding: false)` | Encode a file's contents to URL-safe Base64 |
| `.decode_to_file(encoded, path)` | Decode and write to a file |

## Development

```bash
bundle install
bundle exec rspec
bundle exec rubocop
```

## Support

If you find this project useful:

⭐ [Star the repo](https://github.com/philiprehberger/rb-base64-url)

🐛 [Report issues](https://github.com/philiprehberger/rb-base64-url/issues?q=is%3Aissue+is%3Aopen+label%3Abug)

💡 [Suggest features](https://github.com/philiprehberger/rb-base64-url/issues?q=is%3Aissue+is%3Aopen+label%3Aenhancement)

❤️ [Sponsor development](https://github.com/sponsors/philiprehberger)

🌐 [All Open Source Projects](https://philiprehberger.com/open-source-packages)

💻 [GitHub Profile](https://github.com/philiprehberger)

🔗 [LinkedIn Profile](https://www.linkedin.com/in/philiprehberger)

## License

[MIT](LICENSE)
