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
  end
end
