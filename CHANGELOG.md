# Changelog

All notable changes to this gem will be documented in this file.

The format is based on [Keep a Changelog](https://keepachangelog.com/en/1.0.0/),
and this project adheres to [Semantic Versioning](https://semver.org/spec/v2.0.0.html).

## [Unreleased]

## [0.8.0] - 2026-04-30

### Added
- `Base64Url.encoded_length(bytes)` — number of characters in an unpadded URL-safe Base64 string for `n` bytes of input; inverse of `byte_length`.

## [0.7.0] - 2026-04-22

### Added
- `Base64Url.random(bytes:)` — generate a URL-safe Base64 random token (no padding) from `SecureRandom.bytes`.

## [0.6.0] - 2026-04-16

### Added
- `encode_uuid` and `decode_uuid` for compact 22-character base64url UUID representation

## [0.5.0] - 2026-04-15

### Added
- `to_std(data)` to convert a URL-safe Base64 string to a standard Base64 string (adds `=` padding and swaps `-_` for `+/`)
- `from_std(data)` to convert a standard Base64 string to a URL-safe Base64 string (strips `=` padding and swaps `+/` for `-_`)

## [0.4.0] - 2026-04-09

### Added
- `secure_compare(a, b)` for constant-time string comparison (timing-attack safe)
- `byte_length(encoded)` to calculate decoded byte count without decoding
- `encode_file(path, padding: false)` to encode a file's contents
- `decode_to_file(encoded, path)` to decode and write to a file

## [0.3.0] - 2026-04-04

### Added
- `valid?` method to check if a string is valid URL-safe Base64 without raising

## [0.2.0] - 2026-04-04

### Added
- `padding:` option for `encode` method (default: false)
- GitHub issue template gem version field
- Feature request "Alternatives considered" field

## [0.1.6] - 2026-03-31

### Added
- Add GitHub issue templates, dependabot config, and PR template

## [0.1.5] - 2026-03-31

### Changed
- Standardize README badges, support section, and license format

## [0.1.4] - 2026-03-24

### Fixed
- Standardize README code examples to use double-quote require statements

## [0.1.3] - 2026-03-24

### Fixed
- Fix Installation section quote style to double quotes

## [0.1.2] - 2026-03-22

### Changed
- Expanded test coverage to 30+ examples covering edge cases, error paths, and boundary conditions

## [0.1.1] - 2026-03-22

### Changed
- Version bump for republishing

## [0.1.0] - 2026-03-22

### Added
- Initial release
- URL-safe Base64 encoding and decoding with no padding by default
- JSON encode and decode helpers for hash round-tripping
