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
  end
end
