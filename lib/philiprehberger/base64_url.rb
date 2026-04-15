# frozen_string_literal: true

require 'base64'
require 'json'
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
  end
end
