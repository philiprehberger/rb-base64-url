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

### Convert between URL-safe and standard Base64

```ruby
Philiprehberger::Base64Url.to_std("SGVsbG8")    # => "SGVsbG8="
Philiprehberger::Base64Url.to_std("a-b_c")       # => "a+b/c==="

Philiprehberger::Base64Url.from_std("SGVsbG8=")  # => "SGVsbG8"
Philiprehberger::Base64Url.from_std("a+b/c==")   # => "a-b_c"
```

### Random token

```ruby
Philiprehberger::Base64Url.random
# => "Xk8...k2Q" (43-char URL-safe Base64 of 32 random bytes, no padding)

Philiprehberger::Base64Url.random(bytes: 16)
# => 22-char URL-safe Base64 token
```

### Compact UUIDs

Shorten a 36-character canonical UUID into a 22-character URL-safe Base64 string
(no padding) and decode back to the original canonical form.

```ruby
token = Philiprehberger::Base64Url.encode_uuid("f47ac10b-58cc-4372-a567-0e02b2c3d479")
# => "9HrBC1jMQ3KlZw4Cssx0eQ" (22 chars)

Philiprehberger::Base64Url.decode_uuid(token)
# => "f47ac10b-58cc-4372-a567-0e02b2c3d479"
```

## API

| Method | Description |
|--------|-------------|
| `.encode(data, padding: false)` | Encode data to URL-safe Base64 (optional padding) |
| `Base64Url.random(bytes: 32)` | Generate a URL-safe Base64 random token |
| `.decode(data)` | Decode a URL-safe Base64 string |
| `.encode_json(hash)` | Encode a hash as JSON then URL-safe Base64 |
| `.decode_json(str)` | Decode a URL-safe Base64 string and parse as JSON |
| `.valid?(data)` | Check if a string is valid URL-safe Base64 |
| `.secure_compare(a, b)` | Constant-time comparison of two strings |
| `.byte_length(encoded)` | Calculate decoded byte count without decoding |
| `.encode_file(path, padding: false)` | Encode a file's contents to URL-safe Base64 |
| `.decode_to_file(encoded, path)` | Decode and write to a file |
| `.to_std(data)` | Convert URL-safe Base64 to standard Base64 (adds `=` padding, swaps `-_` for `+/`) |
| `.from_std(data)` | Convert standard Base64 to URL-safe Base64 (strips `=` padding, swaps `+/` for `-_`) |
| `.encode_uuid(uuid)` | Encode a canonical UUID as a compact 22-character URL-safe Base64 string |
| `.decode_uuid(encoded)` | Decode a 22-character URL-safe Base64 string back to a canonical lowercase UUID |

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
