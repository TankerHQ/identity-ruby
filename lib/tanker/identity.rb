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

    def self.assert_string_values(hash)
      hash.each_pair do |key, value|
        unless value.is_a?(String)
          raise TypeError.new("expected #{key} to be a String but was a #{value.class}")
        end
      end
    end

    public

    def self.deserialize(b64_json)
      JSON.parse(Base64.strict_decode64(b64_json))
    end

    def self.serialize(hash)
      Base64.strict_encode64(JSON.generate(hash))
    end

    def self.create_identity(b64_trustchain_id, b64_trustchain_private_key, user_id)
      assert_string_values({
        trustchain_id: b64_trustchain_id,
        trustchain_private_key: b64_trustchain_private_key,
        user_id: user_id
      })

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

    def self.create_provisional_identity(b64_trustchain_id, email)
      assert_string_values({
        trustchain_id: b64_trustchain_id,
        email: email
      })

      encryption_keypair = Crypto.generate_encryption_keypair
      signature_keypair = Crypto.generate_signature_keypair

      serialize({
        trustchain_id: b64_trustchain_id,
        target: 'email',
        value: email,
        public_encryption_key: Base64.strict_encode64(encryption_keypair[:public_key]),
        private_encryption_key: Base64.strict_encode64(encryption_keypair[:private_key]),
        public_signature_key: Base64.strict_encode64(signature_keypair[:public_key]),
        private_signature_key: Base64.strict_encode64(signature_keypair[:private_key])
      })
    end

    def self.get_public_identity(serialized_identity)
      assert_string_values({ identity: serialized_identity })

      identity = deserialize(serialized_identity)

      if identity['target'] == 'user'
        public_keys = ['trustchain_id', 'target', 'value']
      else
        public_keys = ['trustchain_id', 'target', 'value', 'public_encryption_key', 'public_signature_key']
      end

      public_identity = {}
      public_keys.each { |key| public_identity[key] = identity.fetch(key) }

      serialize(public_identity)
    rescue KeyError # failed fetch
      raise ArgumentError.new('Not a valid Tanker identity')
    end

    def self.upgrade_user_token(b64_trustchain_id, user_id, user_token)
      assert_string_values({
        trustchain_id: b64_trustchain_id,
        user_id: user_id,
        user_token: user_token
      })

      identity = deserialize(user_token)
      identity['target'] = 'user'
      identity['trustchain_id'] = b64_trustchain_id
      identity['value'] = identity.delete('user_id')

      serialize(identity)
    end
  end
end
