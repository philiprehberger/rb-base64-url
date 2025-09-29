# frozen_string_literal: true

require 'spec_helper'
require 'tempfile'

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

  describe '.secure_compare' do
    it 'returns true for identical strings' do
      a = described_class.encode('secret token')
      expect(described_class.secure_compare(a, a)).to be true
    end

    it 'returns false for different strings' do
      a = described_class.encode('token_a')
      b = described_class.encode('token_b')
      expect(described_class.secure_compare(a, b)).to be false
    end

    it 'returns false for different lengths' do
      expect(described_class.secure_compare('short', 'much longer')).to be false
    end

    it 'returns true for empty strings' do
      expect(described_class.secure_compare('', '')).to be true
    end
  end

  describe '.byte_length' do
    it 'returns the decoded byte length' do
      encoded = described_class.encode('hello world')
      expect(described_class.byte_length(encoded)).to eq(11)
    end

    it 'returns 0 for empty string' do
      expect(described_class.byte_length('')).to eq(0)
    end

    it 'returns 0 for nil' do
      expect(described_class.byte_length(nil)).to eq(0)
    end

    it 'handles padded input' do
      encoded = described_class.encode('test', padding: true)
      expect(described_class.byte_length(encoded)).to eq(4)
    end

    it 'handles unpadded input' do
      encoded = described_class.encode('test', padding: false)
      expect(described_class.byte_length(encoded)).to eq(4)
    end
  end

  describe '.encode_file' do
    it 'encodes a file to URL-safe Base64' do
      file = Tempfile.new('test')
      file.write('hello world')
      file.close

      result = described_class.encode_file(file.path)
      expect(described_class.decode(result)).to eq('hello world')
    ensure
      file&.unlink
    end

    it 'raises Errno::ENOENT for missing files' do
      expect { described_class.encode_file('/nonexistent/file') }.to raise_error(Errno::ENOENT)
    end
  end

  describe '.decode_to_file' do
    it 'decodes and writes to a file' do
      file = Tempfile.new('test')
      file.close

      encoded = described_class.encode('decoded content')
      described_class.decode_to_file(encoded, file.path)

      expect(File.read(file.path)).to eq('decoded content')
    ensure
      file&.unlink
    end

    it 'handles binary data' do
      file = Tempfile.new('test')
      file.close

      binary = "\x00\x01\xFF"
      encoded = described_class.encode(binary)
      described_class.decode_to_file(encoded, file.path)

      expect(File.binread(file.path).bytes).to eq(binary.bytes)
    ensure
      file&.unlink
    end
  end

  describe '.to_std' do
    it 'replaces - with + and _ with /' do
      expect(described_class.to_std('a-b_c-d_e')).to eq('a+b/c+d/e===')
    end

    it 'adds no padding when length is already a multiple of 4' do
      expect(described_class.to_std('abcd')).to eq('abcd')
    end

    it 'adds three = when length mod 4 is 1' do
      expect(described_class.to_std('a')).to eq('a===')
    end

    it 'adds two = when length mod 4 is 2' do
      expect(described_class.to_std('ab')).to eq('ab==')
    end

    it 'adds one = when length mod 4 is 3' do
      expect(described_class.to_std('abc')).to eq('abc=')
    end

    it 'round trips input with no special characters and no padding needed' do
      expect(described_class.to_std('abcd')).to eq('abcd')
    end

    it 'handles already-padded input by leaving padding alone when length is multiple of 4' do
      expect(described_class.to_std('SGVsbG8=')).to eq('SGVsbG8=')
    end

    it 'handles empty string' do
      expect(described_class.to_std('')).to eq('')
    end

    it 'produces output decodable by standard Base64' do
      encoded = described_class.encode("\xFB\xFF\xFE")
      std = described_class.to_std(encoded)
      expect(Base64.decode64(std).bytes).to eq([0xFB, 0xFF, 0xFE])
    end
  end

  describe '.from_std' do
    it 'replaces + with - and / with _' do
      expect(described_class.from_std('a+b/c+d/e')).to eq('a-b_c-d_e')
    end

    it 'strips trailing = padding' do
      expect(described_class.from_std('SGVsbG8=')).to eq('SGVsbG8')
    end

    it 'strips multiple = characters' do
      expect(described_class.from_std('dGVzdA==')).to eq('dGVzdA')
    end

    it 'leaves input without + / or = unchanged' do
      expect(described_class.from_std('SGVsbG8')).to eq('SGVsbG8')
    end

    it 'handles empty string' do
      expect(described_class.from_std('')).to eq('')
    end

    it 'converts both substitutions and strips padding together' do
      expect(described_class.from_std('a+b/c==')).to eq('a-b_c')
    end
  end

  describe 'to_std / from_std round-trip' do
    it 'round trips when input has no trailing =' do
      ['SGVsbG8', 'a-b_c', 'abcd', 'a', 'ab', 'abc', described_class.encode("\xFF\xFE\xFD")].each do |input|
        expect(described_class.from_std(described_class.to_std(input))).to eq(input)
      end
    end
  end

  describe '.encode_uuid' do
    it 'encodes a canonical UUID to exactly 22 characters' do
      result = described_class.encode_uuid('11111111-2222-3333-4444-555555555555')
      expect(result.length).to eq(22)
    end

    it 'encodes the nil UUID' do
      result = described_class.encode_uuid('00000000-0000-0000-0000-000000000000')
      expect(result.length).to eq(22)
      expect(described_class.decode_uuid(result)).to eq('00000000-0000-0000-0000-000000000000')
    end

    it 'encodes the max UUID' do
      result = described_class.encode_uuid('ffffffff-ffff-ffff-ffff-ffffffffffff')
      expect(result.length).to eq(22)
      expect(described_class.decode_uuid(result)).to eq('ffffffff-ffff-ffff-ffff-ffffffffffff')
    end

    it 'accepts mixed-case input' do
      uuid = 'AbCdEf01-2345-6789-ABCD-ef0123456789'
      result = described_class.encode_uuid(uuid)
      expect(described_class.decode_uuid(result)).to eq(uuid.downcase)
    end

    it 'produces URL-safe output (no + or /)' do
      result = described_class.encode_uuid('ffffffff-ffff-ffff-ffff-ffffffffffff')
      expect(result).not_to match(%r{[+/=]})
    end

    it 'raises ArgumentError on wrong length' do
      expect { described_class.encode_uuid('abc') }.to raise_error(ArgumentError, /invalid UUID/)
    end

    it 'raises ArgumentError on non-hex characters' do
      expect do
        described_class.encode_uuid('zzzzzzzz-zzzz-zzzz-zzzz-zzzzzzzzzzzz')
      end.to raise_error(ArgumentError, /invalid UUID/)
    end

    it 'raises ArgumentError on missing dashes' do
      expect do
        described_class.encode_uuid('00000000000000000000000000000000')
      end.to raise_error(ArgumentError, /invalid UUID/)
    end

    it 'raises ArgumentError on non-String input' do
      expect { described_class.encode_uuid(nil) }.to raise_error(ArgumentError, /must be a String/)
    end
  end

  describe '.decode_uuid' do
    it 'round-trips the nil UUID' do
      uuid = '00000000-0000-0000-0000-000000000000'
      expect(described_class.decode_uuid(described_class.encode_uuid(uuid))).to eq(uuid)
    end

    it 'round-trips the max UUID' do
      uuid = 'ffffffff-ffff-ffff-ffff-ffffffffffff'
      expect(described_class.decode_uuid(described_class.encode_uuid(uuid))).to eq(uuid)
    end

    it 'round-trips a typical v4 UUID' do
      uuid = 'f47ac10b-58cc-4372-a567-0e02b2c3d479'
      expect(described_class.decode_uuid(described_class.encode_uuid(uuid))).to eq(uuid)
    end

    it 'round-trips multiple canonical UUIDs' do
      uuids = %w[
        00000000-0000-0000-0000-000000000000
        ffffffff-ffff-ffff-ffff-ffffffffffff
        f47ac10b-58cc-4372-a567-0e02b2c3d479
        123e4567-e89b-12d3-a456-426614174000
        01020304-0506-0708-090a-0b0c0d0e0f10
      ]
      uuids.each do |uuid|
        expect(described_class.decode_uuid(described_class.encode_uuid(uuid))).to eq(uuid)
      end
    end

    it 'returns lowercase canonical form for mixed-case input' do
      uuid = 'AbCdEf01-2345-6789-ABCD-ef0123456789'
      encoded = described_class.encode_uuid(uuid)
      expect(described_class.decode_uuid(encoded)).to eq(uuid.downcase)
    end

    it 'accepts input with padding' do
      uuid = 'f47ac10b-58cc-4372-a567-0e02b2c3d479'
      encoded = described_class.encode_uuid(uuid)
      padded = "#{encoded}=="
      expect(described_class.decode_uuid(padded)).to eq(uuid)
    end

    it 'raises ArgumentError when decoded length is not 16 bytes' do
      short = described_class.encode('too short')
      expect { described_class.decode_uuid(short) }.to raise_error(ArgumentError, /16 decoded bytes/)
    end

    it 'raises ArgumentError on empty string' do
      expect { described_class.decode_uuid('') }.to raise_error(ArgumentError, /16 decoded bytes/)
    end

    it 'raises ArgumentError on non-String input' do
      expect { described_class.decode_uuid(nil) }.to raise_error(ArgumentError, /must be a String/)
    end

    it 'raises ArgumentError on malformed Base64' do
      expect { described_class.decode_uuid('!!!') }.to raise_error(ArgumentError, /invalid encoded UUID/)
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
