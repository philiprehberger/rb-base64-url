# frozen_string_literal: true

require 'base64'
require 'json'
require 'securerandom'
require_relative 'base64_url/version'

module Philiprehberger
  module Base64Url
    class Error < StandardError; end

    # Encode data to URL-safe Base64
    #
    # @param data [String] the data to encode
    # @param padding [Boolean] whether to include padding (default: false)
    # @return [String] URL-safe Base64 encoded string
    def self.encode(data, padding: false)
      Base64.urlsafe_encode64(data, padding: padding)
    end

    # Decode URL-safe Base64 data
    #
    # @param data [String] the Base64 string to decode
    # @return [String] decoded data
    # @raise [Error] if data cannot be decoded
    def self.decode(data)
      Base64.urlsafe_decode64(data)
    rescue ArgumentError => e
      raise Error, "invalid Base64: #{e.message}"
    end

    # Encode a hash as JSON then URL-safe Base64
    #
    # @param hash [Hash] the hash to encode
    # @return [String] URL-safe Base64 encoded JSON string
    def self.encode_json(hash)
      encode(JSON.generate(hash))
    end

    # Decode a URL-safe Base64 string and parse as JSON
    #
    # @param str [String] the Base64 encoded JSON string
    # @return [Hash] the decoded hash
    # @raise [Error] if string cannot be decoded or parsed
    def self.decode_json(str)
      JSON.parse(decode(str))
    rescue JSON::ParserError => e
      raise Error, "invalid JSON: #{e.message}"
    end

    # Check if a string is valid URL-safe Base64
    #
    # @param data [String] the string to validate
    # @return [Boolean] true if valid, false otherwise
    def self.valid?(data)
      decode(data)
      true
    rescue Error
      false
    end

    # Constant-time comparison of two Base64 strings.
    #
    # Prevents timing attacks by always comparing all bytes.
    #
    # @param a [String] first string
    # @param b [String] second string
    # @return [Boolean] true if strings are equal
    def self.secure_compare(a, b)
      return false unless a.bytesize == b.bytesize

      left = a.unpack('C*')
      right = b.unpack('C*')
      result = 0

      left.each_with_index { |byte, i| result |= byte ^ right[i] }

      result.zero?
    end

    # Calculate the decoded byte length from an encoded string without decoding.
    #
    # @param encoded [String] URL-safe Base64 string
    # @return [Integer] number of bytes in the decoded output
    def self.byte_length(encoded)
      return 0 if encoded.nil? || encoded.empty?

      stripped = encoded.delete('=')
      padding = (4 - (stripped.length % 4)) % 4
      ((stripped.length + padding) * 3 / 4) - padding
    end

    # Encode a file's contents to URL-safe Base64.
    #
    # @param path [String] path to the file
    # @param padding [Boolean] whether to include padding (default: false)
    # @return [String] URL-safe Base64 encoded contents
    # @raise [Errno::ENOENT] if the file does not exist
    def self.encode_file(path, padding: false)
      encode(File.binread(path), padding: padding)
    end

    # Generate a URL-safe Base64 random token
    #
    # Encodes `SecureRandom.bytes(bytes)` with URL-safe Base64 and no padding.
    # Useful for session IDs, one-time tokens, and CSRF values that must be safe
    # to pass in URLs and cookies.
    #
    # @param bytes [Integer] number of random bytes to generate (default: 32)
    # @return [String] URL-safe Base64 encoded random token (no padding)
    # @raise [ArgumentError] if bytes is negative
    def self.random(bytes: 32)
      raise ArgumentError, 'bytes must be non-negative' if bytes.negative?

      encode(SecureRandom.bytes(bytes))
    end

    # Decode a URL-safe Base64 string and write to a file.
    #
    # @param encoded [String] URL-safe Base64 string
    # @param path [String] output file path
    # @return [void]
    # @raise [Error] if the string cannot be decoded
    def self.decode_to_file(encoded, path)
      File.binwrite(path, decode(encoded))
    end

    # Convert a URL-safe Base64 string to a standard Base64 string.
    #
    # Replaces `-` with `+`, `_` with `/`, and adds `=` padding so the length
    # is a multiple of 4. Does not validate or decode the input.
    #
    # @param data [String] URL-safe Base64 string
    # @return [String] standard Base64 string
    def self.to_std(data)
      converted = data.tr('-_', '+/')
      padding = (4 - (converted.length % 4)) % 4
      converted + ('=' * padding)
    end

    # Convert a standard Base64 string to a URL-safe Base64 string.
    #
    # Replaces `+` with `-`, `/` with `_`, and strips trailing `=` padding.
    # Does not validate or decode the input.
    #
    # @param data [String] standard Base64 string
    # @return [String] URL-safe Base64 string
    def self.from_std(data)
      data.tr('+/', '-_').delete('=')
    end

    UUID_REGEX = /\A[0-9a-f]{8}-[0-9a-f]{4}-[0-9a-f]{4}-[0-9a-f]{4}-[0-9a-f]{12}\z/i
    private_constant :UUID_REGEX

    # Encode a canonical UUID as a compact 22-character URL-safe Base64 string.
    #
    # Strips dashes, packs the 32 hex characters into 16 binary bytes, then
    # URL-safe Base64 encodes without padding. Accepts mixed-case input.
    #
    # @param uuid [String] canonical UUID ("xxxxxxxx-xxxx-xxxx-xxxx-xxxxxxxxxxxx")
    # @return [String] 22-character URL-safe Base64 string (no padding)
    # @raise [ArgumentError] if the input is not a canonical UUID
    def self.encode_uuid(uuid)
      raise ArgumentError, 'uuid must be a String' unless uuid.is_a?(String)
      raise ArgumentError, "invalid UUID: #{uuid.inspect}" unless UUID_REGEX.match?(uuid)

      bytes = [uuid.delete('-')].pack('H*')
      Base64.urlsafe_encode64(bytes, padding: false)
    end

    # Decode a 22-character URL-safe Base64 string back to a canonical UUID.
    #
    # Accepts input with or without `=` padding. Returns a lowercase
    # canonical UUID ("xxxxxxxx-xxxx-xxxx-xxxx-xxxxxxxxxxxx").
    #
    # @param encoded [String] 22-character URL-safe Base64 string
    # @return [String] canonical lowercase UUID
    # @raise [ArgumentError] if the decoded byte length is not exactly 16
    def self.decode_uuid(encoded)
      raise ArgumentError, 'encoded must be a String' unless encoded.is_a?(String)

      begin
        bytes = Base64.urlsafe_decode64(encoded)
      rescue ArgumentError => e
        raise ArgumentError, "invalid encoded UUID: #{e.message}"
      end

      unless bytes.bytesize == 16
        raise ArgumentError, "invalid encoded UUID: expected 16 decoded bytes, got #{bytes.bytesize}"
      end

      hex = bytes.unpack1('H*')
      "#{hex[0, 8]}-#{hex[8, 4]}-#{hex[12, 4]}-#{hex[16, 4]}-#{hex[20, 12]}"
    end
  end
end
