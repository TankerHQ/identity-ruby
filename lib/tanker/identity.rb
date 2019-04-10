require 'tanker/crypto'
require 'base64'
require 'json'

module Tanker
  module Identity
    BLOCK_HASH_SIZE = 32
    USER_SECRET_SIZE = 32

    private

    def self.hash_user_id(trustchain_id, user_id)
      binary_user_id = user_id.dup.force_encoding(Encoding::ASCII_8BIT)
      Crypto.generichash(binary_user_id + trustchain_id, BLOCK_HASH_SIZE)
    end

    def self.user_secret(hashed_user_id)
      random_bytes = Crypto.random_bytes(USER_SECRET_SIZE - 1)
      check = Crypto.generichash(random_bytes + hashed_user_id, Crypto::HASH_MIN_SIZE)
      random_bytes + check[0]
    end

    public

    def self.deserialize(b64_json)
      JSON.parse(Base64.strict_decode64(b64_json))
    end

    def self.serialize(hash)
      Base64.strict_encode64(JSON.generate(hash))
    end

    def self.create_identity(b64_trustchain_id, b64_trustchain_private_key, user_id)
      trustchain_id = Base64.strict_decode64(b64_trustchain_id)
      trustchain_private_key = Base64.strict_decode64(b64_trustchain_private_key)

      hashed_user_id = hash_user_id(trustchain_id, user_id)
      signature_keypair = Crypto.generate_signature_keypair
      message = signature_keypair[:public_key] + hashed_user_id
      signature = Crypto.sign_detached(message, trustchain_private_key)

      serialize({
        trustchain_id: Base64.strict_encode64(trustchain_id),
        target: 'user',
        value: Base64.strict_encode64(hashed_user_id),
        delegation_signature: Base64.strict_encode64(signature),
        ephemeral_public_signature_key: Base64.strict_encode64(signature_keypair[:public_key]),
        ephemeral_private_signature_key: Base64.strict_encode64(signature_keypair[:private_key]),
        user_secret: Base64.strict_encode64(user_secret(hashed_user_id))
      })
    end
  end
end
