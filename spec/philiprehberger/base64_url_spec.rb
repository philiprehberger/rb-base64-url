# frozen_string_literal: true

require 'spec_helper'

RSpec.describe Philiprehberger::Base64Url do
  it 'has a version number' do
    expect(described_class::VERSION).not_to be_nil
  end

  describe '.encode' do
    it 'encodes a string to URL-safe Base64' do
      result = described_class.encode('hello world')
      expect(result).to eq('aGVsbG8gd29ybGQ')
    end

    it 'does not include padding by default' do
      result = described_class.encode('test')
      expect(result).not_to include('=')
    end

    it 'produces URL-safe output' do
      result = described_class.encode("\xFF\xFE")
      expect(result).not_to match(%r{[+/]})
    end

    it 'handles empty string' do
      expect(described_class.encode('')).to eq('')
    end

    it 'encodes a single character' do
      result = described_class.encode('a')
      expect(described_class.decode(result)).to eq('a')
    end

    it 'encodes whitespace-only string' do
      result = described_class.encode('   ')
      expect(described_class.decode(result)).to eq('   ')
    end

    it 'encodes unicode characters' do
      result = described_class.encode("\u{1F600}")
      expect(described_class.decode(result).force_encoding('UTF-8')).to eq("\u{1F600}")
    end

    it 'encodes a long string' do
      long_str = 'abcdefghij' * 1000
      result = described_class.encode(long_str)
      expect(described_class.decode(result)).to eq(long_str)
    end

    it 'encodes newlines and tabs' do
      result = described_class.encode("line1\nline2\ttab")
      expect(described_class.decode(result)).to eq("line1\nline2\ttab")
    end

    it 'encodes binary data with null bytes' do
      binary = "\x00\x01\x02\xFF"
      result = described_class.encode(binary)
      expect(described_class.decode(result).bytes).to eq(binary.bytes)
    end

    it 'produces different output for different inputs' do
      a = described_class.encode('hello')
      b = described_class.encode('world')
      expect(a).not_to eq(b)
    end

    it 'uses - instead of + for URL safety' do
      # The byte 0xFB encodes to a value that uses + in standard Base64
      data = "\xFB\xFF"
      result = described_class.encode(data)
      expect(result).not_to include('+')
    end

    it 'uses _ instead of / for URL safety' do
      data = "\xFF\xFF"
      result = described_class.encode(data)
      expect(result).not_to include('/')
    end
  end

  describe '.encode with padding' do
    it 'omits padding by default' do
      result = described_class.encode('Hello')
      expect(result).not_to end_with('=')
    end

    it 'includes padding when requested' do
      result = described_class.encode('Hello', padding: true)
      expect(result).to end_with('=') if result.length % 4 != 0 || result.include?('=')
    end

    it 'produces decodable output with padding' do
      encoded = described_class.encode('test data', padding: true)
      expect(described_class.decode(encoded)).to eq('test data')
    end

    it 'produces decodable output without padding' do
      encoded = described_class.encode('test data', padding: false)
      expect(described_class.decode(encoded)).to eq('test data')
    end
  end

  describe '.decode' do
    it 'decodes a URL-safe Base64 string' do
      expect(described_class.decode('aGVsbG8gd29ybGQ')).to eq('hello world')
    end

    it 'handles padded input' do
      expect(described_class.decode('dGVzdA==')).to eq('test')
    end

    it 'raises Error for invalid input' do
      expect { described_class.decode('!!!') }.to raise_error(described_class::Error)
    end

    it 'decodes empty string' do
      expect(described_class.decode('')).to eq('')
    end

    it 'raises Error with descriptive message' do
      expect { described_class.decode('!!!') }.to raise_error(described_class::Error, /invalid Base64/)
    end

    it 'decodes URL-safe characters correctly' do
      # Test with data containing - and _
      encoded = described_class.encode("\xFF\xFE\xFD")
      expect(described_class.decode(encoded).bytes).to eq([0xFF, 0xFE, 0xFD])
    end

    it 'handles input without padding' do
      # 'dGVzdA' is 'test' without padding
      expect(described_class.decode('dGVzdA')).to eq('test')
    end
  end

  describe '.encode_json' do
    it 'encodes a hash as Base64 JSON' do
      result = described_class.encode_json({ 'key' => 'value' })
      decoded = described_class.decode(result)
      expect(JSON.parse(decoded)).to eq({ 'key' => 'value' })
    end

    it 'handles nested hashes' do
      hash = { 'a' => { 'b' => 1 } }
      result = described_class.encode_json(hash)
      expect(described_class.decode_json(result)).to eq(hash)
    end

    it 'handles empty hash' do
      result = described_class.encode_json({})
      expect(described_class.decode_json(result)).to eq({})
    end

    it 'handles hash with array values' do
      hash = { 'items' => [1, 2, 3] }
      result = described_class.encode_json(hash)
      expect(described_class.decode_json(result)).to eq(hash)
    end

    it 'handles hash with null values' do
      hash = { 'key' => nil }
      result = described_class.encode_json(hash)
      expect(described_class.decode_json(result)).to eq(hash)
    end

    it 'handles hash with unicode values' do
      hash = { 'name' => 'cafe' }
      result = described_class.encode_json(hash)
      expect(described_class.decode_json(result)).to eq(hash)
    end

    it 'handles hash with numeric values' do
      hash = { 'int' => 42, 'float' => 3.14 }
      result = described_class.encode_json(hash)
      decoded = described_class.decode_json(result)
      expect(decoded['int']).to eq(42)
      expect(decoded['float']).to eq(3.14)
    end
  end

  describe '.decode_json' do
    it 'decodes a Base64 JSON string to a hash' do
      encoded = described_class.encode_json({ 'name' => 'test' })
      expect(described_class.decode_json(encoded)).to eq({ 'name' => 'test' })
    end

    it 'raises Error for invalid JSON' do
      encoded = described_class.encode('not json')
      expect { described_class.decode_json(encoded) }.to raise_error(described_class::Error, /invalid JSON/)
    end

    it 'raises Error for invalid Base64 within decode_json' do
      expect { described_class.decode_json('!!!') }.to raise_error(described_class::Error)
    end

    it 'decodes arrays encoded as JSON' do
      encoded = described_class.encode('[1,2,3]')
      result = described_class.decode_json(encoded)
      expect(result).to eq([1, 2, 3])
    end
  end

  describe '.valid?' do
    it 'returns true for a valid Base64 string' do
      encoded = described_class.encode('hello world')
      expect(described_class.valid?(encoded)).to be true
    end

    it 'returns true for an empty string' do
      expect(described_class.valid?('')).to be true
    end

    it 'returns true for a padded Base64 string' do
      expect(described_class.valid?('dGVzdA==')).to be true
    end

    it 'returns false for invalid Base64' do
      expect(described_class.valid?('!!!')).to be false
    end

    it 'returns true for Base64 encoded JSON' do
      encoded = described_class.encode_json({ 'key' => 'value' })
      expect(described_class.valid?(encoded)).to be true
    end

    it 'returns true for URL-safe characters' do
      encoded = described_class.encode("\xFF\xFE\xFD")
      expect(described_class.valid?(encoded)).to be true
    end
  end

  describe 'roundtrip' do
    it 'roundtrips simple strings' do
      %w[hello test 123 foo-bar].each do |str|
        expect(described_class.decode(described_class.encode(str))).to eq(str)
      end
    end

    it 'roundtrips binary data' do
      data = (0..255).map(&:chr).join
      expect(described_class.decode(described_class.encode(data))).to eq(data)
    end

    it 'roundtrips JSON hashes' do
      hash = { 'users' => [{ 'name' => 'Alice' }, { 'name' => 'Bob' }] }
      expect(described_class.decode_json(described_class.encode_json(hash))).to eq(hash)
    end
  end
end
