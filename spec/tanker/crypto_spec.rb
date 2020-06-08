# typed: false
# frozen_string_literal: true
require 'base64'

RSpec.describe Tanker::Crypto do
  describe('generichash') do
    it 'should match the RFC7693 BLAKE2b-512 test vector for "abc"' do
      # To check that the hash function is implemented correctly, we compute a test vector,
      #  which is a known expected output for a given input, defined in the standard
      hex_vector = 'BA80A53F981C4D0D6A2797B69F12F6E94C212F14685AC4B74B12BB6FDBFFA2D17D87C5392AAB792DC252D5DE4533CC9518D38AA8DBF1925AB92386EDD4009923'
      vector = [hex_vector].pack('H*')
      input = 'abc'.dup.force_encoding(Encoding::ASCII_8BIT)
      output = Tanker::Crypto.generichash(input, 64)

      expect(output).to eq(vector)
    end
  end

  describe('signatures') do
    before(:all) do
      signature_keypair = Tanker::Crypto.generate_signature_keypair

      @message = 'message'.dup.force_encoding(Encoding::ASCII_8BIT)
      @public_key = signature_keypair[:public_key]
      @signature = Tanker::Crypto.sign_detached(@message, signature_keypair[:private_key])
    end

    it 'should sign and verify using existing keypair' do
      public_key = Base64.decode64(test_app[:public_key])
      secret = Base64.decode64(test_app[:secret])
      signature = Tanker::Crypto.sign_detached(@message, secret)
      Tanker::Crypto.verify_sign_detached(@message, signature, public_key)
    end

    it 'should verify a valid signature using a generated signature keypair' do
      Tanker::Crypto.verify_sign_detached(@message, @signature, @public_key)
    end

    it 'should fail to verify an invalid message' do
      invalid_message = corrupt_binary(@message)

      expect {
        Tanker::Crypto.verify_sign_detached(invalid_message, @signature, @public_key)
      }.to raise_exception(Tanker::Crypto::InvalidSignature)
    end

    it 'should fail to verify an invalid signature' do
      invalid_signature = corrupt_binary(@signature)

      expect {
        Tanker::Crypto.verify_sign_detached(@message, invalid_signature, @public_key)
      }.to raise_exception(Tanker::Crypto::InvalidSignature)
    end
  end
end
