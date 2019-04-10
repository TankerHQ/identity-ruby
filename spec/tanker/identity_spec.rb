# frozen_string_literal: true
RSpec.describe Tanker::Identity do
  before(:all) do
    # Note: vectors below were generated with the Javascript SDK. We keep it to
    #       check Javascript and Ruby code are interoperable
    @trustchain = test_trustchain
    @user_id = 'b_eich'
    @hashed_user_id = 'RDa0eq4XNuj5tV7hdapjOxhmheTh4QBDNpy4Svy9Xok='
    @permanent_identity = 'eyJ0cnVzdGNoYWluX2lkIjoidHBveHlOemgwaFU5RzJpOWFnTXZIeXlkK3BPNnpHQ2pPOUJmaHJDTGpkND0iLCJ0YXJnZXQiOiJ1c2VyIiwidmFsdWUiOiJSRGEwZXE0WE51ajV0VjdoZGFwak94aG1oZVRoNFFCRE5weTRTdnk5WG9rPSIsImRlbGVnYXRpb25fc2lnbmF0dXJlIjoiVTlXUW9sQ3ZSeWpUOG9SMlBRbWQxV1hOQ2kwcW1MMTJoTnJ0R2FiWVJFV2lyeTUya1d4MUFnWXprTHhINmdwbzNNaUE5cisremhubW9ZZEVKMCtKQ3c9PSIsImVwaGVtZXJhbF9wdWJsaWNfc2lnbmF0dXJlX2tleSI6IlhoM2kweERUcHIzSFh0QjJRNTE3UUt2M2F6TnpYTExYTWRKRFRTSDRiZDQ9IiwiZXBoZW1lcmFsX3ByaXZhdGVfc2lnbmF0dXJlX2tleSI6ImpFRFQ0d1FDYzFERndvZFhOUEhGQ2xuZFRQbkZ1Rm1YaEJ0K2lzS1U0WnBlSGVMVEVOT212Y2RlMEhaRG5YdEFxL2RyTTNOY3N0Y3gwa05OSWZodDNnPT0iLCJ1c2VyX3NlY3JldCI6IjdGU2YvbjBlNzZRVDNzMERrdmV0UlZWSmhYWkdFak94ajVFV0FGZXh2akk9In0='
  end

  describe 'parse' do
    it 'a valid permanent identity' do
      identity = Tanker::Identity.deserialize(@permanent_identity)

      expect(identity['trustchain_id']).to eq(@trustchain[:id])
      expect(identity['target']).to eq('user')
      expect(identity['value']).to eq(@hashed_user_id)
      expect(identity['delegation_signature']).to eq('U9WQolCvRyjT8oR2PQmd1WXNCi0qmL12hNrtGabYREWiry52kWx1AgYzkLxH6gpo3MiA9r++zhnmoYdEJ0+JCw==')
      expect(identity['ephemeral_public_signature_key']).to eq('Xh3i0xDTpr3HXtB2Q517QKv3azNzXLLXMdJDTSH4bd4=')
      expect(identity['ephemeral_private_signature_key']).to eq('jEDT4wQCc1DFwodXNPHFClndTPnFuFmXhBt+isKU4ZpeHeLTENOmvcde0HZDnXtAq/drM3Ncstcx0kNNIfht3g==')
      expect(identity['user_secret']).to eq('7FSf/n0e76QT3s0DkvetRVVJhXZGEjOxj5EWAFexvjI=')
    end
  end

  describe 'permanent identity' do
    def assert_user_secret(identity)
      hashed_user_id = Base64.decode64(@identity['value'])
      user_secret = Base64.decode64(@identity['user_secret'])
      expect(hashed_user_id.bytesize).to be 32
      expect(user_secret.bytesize).to be 32

      control_byte = user_secret.bytes.last
      control = Tanker::Crypto.generichash(user_secret[0..-2] + hashed_user_id, Tanker::Crypto::HASH_MIN_SIZE)
      expect(control_byte).to eq(control.bytes.first)
    end

    def assert_signature(identity, trustchain_public_key)
      signed_data = Base64.decode64(identity['ephemeral_public_signature_key']) +
                    Base64.decode64(identity['value'])

      signature = Base64.decode64(identity['delegation_signature'])
      public_key = Base64.decode64(trustchain_public_key)

      expect {
        Tanker::Crypto.verify_sign_detached(signed_data, signature, public_key)
      }.not_to raise_exception # no Tanker::Crypto::InvalidSignature
    end

    before(:all) do
      @b64_identity = Tanker::Identity.create_identity(@trustchain[:id], @trustchain[:private_key], @user_id)
      @identity = Tanker::Identity.deserialize(@b64_identity)
    end

    it 'returns a permanent identity' do
      expect(@identity.keys.sort).to eq ['delegation_signature', 'ephemeral_private_signature_key', 'ephemeral_public_signature_key', 'target', 'trustchain_id', 'user_secret', 'value']
      expect(@identity['trustchain_id']).to eq @trustchain[:id]
      expect(@identity['target']).to eq 'user'
      assert_user_secret(@identity)
      assert_signature(@identity, @trustchain[:public_key])
    end
  end
end
