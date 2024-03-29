require 'tanker/crypto'
require 'tanker/identity/version'
require 'base64'
require 'json'

module Tanker
  module Identity
    APP_CREATION_NATURE = 1
    APP_SECRET_SIZE = 64
    APP_PUBLIC_KEY_SIZE = 32
    AUTHOR_SIZE = 32
    USER_SECRET_SIZE = 32

    private

    def self.user_secret(hashed_user_id)
      random_bytes = Crypto.random_bytes(USER_SECRET_SIZE - 1)
      check = Crypto.generichash(random_bytes + hashed_user_id, Crypto::HASH_MIN_SIZE)
      random_bytes + check[0]
    end

    def self.assert_string_values(hash)
      hash.each_pair do |key, value|
        raise TypeError, "expected #{key} to be a String but was a #{value.class}" unless value.is_a?(String)
      end
    end

    def self.generate_app_id(app_secret)
      block_nature = APP_CREATION_NATURE.chr(Encoding::ASCII_8BIT)
      none_author = 0.chr(Encoding::ASCII_8BIT) * AUTHOR_SIZE
      app_public_key = app_secret[-APP_PUBLIC_KEY_SIZE..-1]
      Crypto.generichash(block_nature + none_author + app_public_key, Crypto::BLOCK_HASH_SIZE)
    end

    public

    def self.deserialize(b64_json)
      JSON.parse(Base64.strict_decode64(b64_json))
    end

    def self.serialize(hash)
      Base64.strict_encode64(JSON.generate(hash))
    end

    def self.create_identity(b64_app_id, b64_app_secret, user_id)
      assert_string_values({
                             app_id: b64_app_id,
                             app_secret: b64_app_secret,
                             user_id: user_id
                           })

      app_id = Base64.strict_decode64(b64_app_id)
      app_secret = Base64.strict_decode64(b64_app_secret)

      raise ArgumentError, "Invalid app_id" if app_id.bytesize != Crypto::BLOCK_HASH_SIZE
      raise ArgumentError, "Invalid app_secret" if app_secret.bytesize != APP_SECRET_SIZE
      raise ArgumentError, "Invalid (app_id, app_secret) combination" if app_id != generate_app_id(app_secret)

      hashed_user_id = Crypto.hash_user_id(app_id, user_id)
      signature_keypair = Crypto.generate_signature_keypair
      message = signature_keypair[:public_key] + hashed_user_id
      signature = Crypto.sign_detached(message, app_secret)

      serialize({
                  trustchain_id: Base64.strict_encode64(app_id),
                  target: 'user',
                  value: Base64.strict_encode64(hashed_user_id),
                  delegation_signature: Base64.strict_encode64(signature),
                  ephemeral_public_signature_key: Base64.strict_encode64(signature_keypair[:public_key]),
                  ephemeral_private_signature_key: Base64.strict_encode64(signature_keypair[:private_key]),
                  user_secret: Base64.strict_encode64(user_secret(hashed_user_id))
                })
    end

    def self.create_provisional_identity(b64_app_id, target, value)
      assert_string_values({
                             app_id: b64_app_id,
                             target: target,
                             value: value
                           })

      valid_targets = %w[email phone_number]
      unless valid_targets.include? target
        raise ArgumentError, "expected #{target} to be one of #{valid_targets.join(', ')}"
      end

      app_id = Base64.strict_decode64(b64_app_id)
      raise ArgumentError, "Invalid app_id" if app_id.bytesize != Crypto::BLOCK_HASH_SIZE

      encryption_keypair = Crypto.generate_encryption_keypair
      signature_keypair = Crypto.generate_signature_keypair

      serialize({
                  trustchain_id: b64_app_id,
                  target: target,
                  value: value,
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

      if identity['target'] == 'email'
        public_identity['target'] = 'hashed_email'
        public_identity['value'] = Crypto.hashed_provisional_email(public_identity['value'])
      elsif identity['target'] != 'user'
        public_identity['target'] = 'hashed_' + public_identity['target']
        public_identity['value'] = Crypto.hashed_provisional_value(public_identity['value'],
                                                                   identity['private_signature_key'])
      end

      serialize(public_identity)
    rescue KeyError # failed fetch
      raise ArgumentError, 'Not a valid Tanker identity'
    end

    def self.upgrade_identity(serialized_identity)
      assert_string_values({ identity: serialized_identity })

      identity = deserialize(serialized_identity)
      if identity['target'] == 'email' && !identity.key?('private_encryption_key')
        identity['target'] = 'hashed_email'
        identity['value'] = Crypto.hashed_provisional_email(identity['value'])
      end
      serialize(identity)
    end
  end
end
