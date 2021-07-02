# frozen_string_literal: true
require 'rbnacl'
require 'securerandom'

module Tanker
  module Crypto
    class InvalidSignature < StandardError; end

    HASH_MIN_SIZE = RbNaCl::Hash::Blake2b::BYTES_MIN # 16
    BLOCK_HASH_SIZE = 32

    def self.generichash(input, size)
      binary_input = input.dup.force_encoding(Encoding::ASCII_8BIT)
      RbNaCl::Hash.blake2b(binary_input, digest_size: size)
    end

    def self.hash_user_id(app_id, user_id)
      binary_user_id = user_id.dup.force_encoding(Encoding::ASCII_8BIT)
      Crypto.generichash(binary_user_id + app_id, BLOCK_HASH_SIZE)
    end

    def self.hashed_provisional_email(email)
      Base64.strict_encode64(Crypto.generichash(email, BLOCK_HASH_SIZE))
    end

    def self.hashed_provisional_value(value, private_signature_key)
      secret_salt = Crypto.generichash(Base64.strict_decode64(private_signature_key), BLOCK_HASH_SIZE)
      Base64.strict_encode64(Crypto.generichash(secret_salt + value, BLOCK_HASH_SIZE))
    end

    # We need this static method since a RbNaCl::SigningKey instance can't be
    # directly initialized with a given private_signature_key
    def self.sign_detached(message, private_signature_key)
      signature_bytes = RbNaCl::SigningKey.signature_bytes
      buffer = RbNaCl::Util.prepend_zeros(signature_bytes, message)
      buffer_len = RbNaCl::Util.zeros(8) # 8 bytes for an int64 (FFI::Type::LONG_LONG.size)

      RbNaCl::SigningKey.sign_ed25519(buffer, buffer_len, message, message.bytesize, private_signature_key)

      buffer[0, signature_bytes]
    end

    def self.verify_sign_detached(message, signature, public_signature_key)
      verify_key = RbNaCl::VerifyKey.new(public_signature_key)
      verify_key.verify(signature, message)
    rescue RbNaCl::BadSignatureError
      raise InvalidSignature.new
    end

    def self.generate_signature_keypair
      signing_key = RbNaCl::SigningKey.generate

      {
        private_key: signing_key.keypair_bytes,
        public_key: signing_key.verify_key.to_bytes
      }
    end

    def self.generate_encryption_keypair
      encryption_key = RbNaCl::PrivateKey.generate

      {
        private_key: encryption_key.to_bytes,
        public_key: encryption_key.public_key.to_bytes
      }
    end

    def self.random_bytes(size)
      SecureRandom.bytes(size)
    end
  end
end
