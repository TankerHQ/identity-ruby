# frozen_string_literal: true
require 'rbnacl'

module Tanker
  module Crypto
    class InvalidSignature < StandardError; end

    HASH_MIN_SIZE = RbNaCl::Hash::Blake2b::BYTES_MIN # 16

    def self.generichash(input, size)
      binary_input = input.dup.force_encoding(Encoding::ASCII_8BIT)
      RbNaCl::Hash.blake2b(binary_input, digest_size: size)
    end
  end
end
