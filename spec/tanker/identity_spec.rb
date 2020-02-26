# frozen_string_literal: true
require 'base64'

RSpec.describe Tanker::Identity do
  before(:all) do
    # Note: vectors below were generated with the Javascript SDK. We keep it to
    #       check Javascript and Ruby code are interoperable
    @app = test_app
    @user_id = 'b_eich'
    @user_email = 'brendan.eich@tanker.io'
    @hashed_user_id = 'RDa0eq4XNuj5tV7hdapjOxhmheTh4QBDNpy4Svy9Xok='
    @permanent_identity = 'eyJ0cnVzdGNoYWluX2lkIjoidHBveHlOemgwaFU5RzJpOWFnTXZIeXlkK3BPNnpHQ2pPOUJmaHJDTGpkND0iLCJ0YXJnZXQiOiJ1c2VyIiwidmFsdWUiOiJSRGEwZXE0WE51ajV0VjdoZGFwak94aG1oZVRoNFFCRE5weTRTdnk5WG9rPSIsImRlbGVnYXRpb25fc2lnbmF0dXJlIjoiVTlXUW9sQ3ZSeWpUOG9SMlBRbWQxV1hOQ2kwcW1MMTJoTnJ0R2FiWVJFV2lyeTUya1d4MUFnWXprTHhINmdwbzNNaUE5cisremhubW9ZZEVKMCtKQ3c9PSIsImVwaGVtZXJhbF9wdWJsaWNfc2lnbmF0dXJlX2tleSI6IlhoM2kweERUcHIzSFh0QjJRNTE3UUt2M2F6TnpYTExYTWRKRFRTSDRiZDQ9IiwiZXBoZW1lcmFsX3ByaXZhdGVfc2lnbmF0dXJlX2tleSI6ImpFRFQ0d1FDYzFERndvZFhOUEhGQ2xuZFRQbkZ1Rm1YaEJ0K2lzS1U0WnBlSGVMVEVOT212Y2RlMEhaRG5YdEFxL2RyTTNOY3N0Y3gwa05OSWZodDNnPT0iLCJ1c2VyX3NlY3JldCI6IjdGU2YvbjBlNzZRVDNzMERrdmV0UlZWSmhYWkdFak94ajVFV0FGZXh2akk9In0='
    @provisional_identity = 'eyJ0cnVzdGNoYWluX2lkIjoidHBveHlOemgwaFU5RzJpOWFnTXZIeXlkK3BPNnpHQ2pPOUJmaHJDTGpkND0iLCJ0YXJnZXQiOiJlbWFpbCIsInZhbHVlIjoiYnJlbmRhbi5laWNoQHRhbmtlci5pbyIsInB1YmxpY19lbmNyeXB0aW9uX2tleSI6Ii8yajRkSTNyOFBsdkNOM3VXNEhoQTV3QnRNS09jQUNkMzhLNk4wcSttRlU9IiwicHJpdmF0ZV9lbmNyeXB0aW9uX2tleSI6IjRRQjVUV212Y0JyZ2V5RERMaFVMSU5VNnRicUFPRVE4djlwakRrUGN5YkE9IiwicHVibGljX3NpZ25hdHVyZV9rZXkiOiJXN1FFUUJ1OUZYY1hJcE9ncTYydFB3Qml5RkFicFQxckFydUQwaC9OclRBPSIsInByaXZhdGVfc2lnbmF0dXJlX2tleSI6IlVtbll1dmRUYUxZRzBhK0phRHBZNm9qdzQvMkxsOHpzbXJhbVZDNGZ1cVJidEFSQUc3MFZkeGNpazZDcnJhMC9BR0xJVUJ1bFBXc0N1NFBTSDgydE1BPT0ifQ=='
    @public_identity = 'eyJ0YXJnZXQiOiJ1c2VyIiwidHJ1c3RjaGFpbl9pZCI6InRwb3h5TnpoMGhVOUcyaTlhZ012SHl5ZCtwTzZ6R0NqTzlCZmhyQ0xqZDQ9IiwidmFsdWUiOiJSRGEwZXE0WE51ajV0VjdoZGFwak94aG1oZVRoNFFCRE5weTRTdnk5WG9rPSJ9'
    @public_provisional_identity = 'eyJ0cnVzdGNoYWluX2lkIjoidHBveHlOemgwaFU5RzJpOWFnTXZIeXlkK3BPNnpHQ2pPOUJmaHJDTGpkND0iLCJ0YXJnZXQiOiJlbWFpbCIsInZhbHVlIjoiYnJlbmRhbi5laWNoQHRhbmtlci5pbyIsInB1YmxpY19lbmNyeXB0aW9uX2tleSI6Ii8yajRkSTNyOFBsdkNOM3VXNEhoQTV3QnRNS09jQUNkMzhLNk4wcSttRlU9IiwicHVibGljX3NpZ25hdHVyZV9rZXkiOiJXN1FFUUJ1OUZYY1hJcE9ncTYydFB3Qml5RkFicFQxckFydUQwaC9OclRBPSJ9'
  end

  describe 'parse' do
    it 'a valid permanent identity' do
      identity = Tanker::Identity.deserialize(@permanent_identity)

      expect(identity['trustchain_id']).to eq(@app[:id])
      expect(identity['target']).to eq('user')
      expect(identity['value']).to eq(@hashed_user_id)
      expect(identity['delegation_signature']).to eq('U9WQolCvRyjT8oR2PQmd1WXNCi0qmL12hNrtGabYREWiry52kWx1AgYzkLxH6gpo3MiA9r++zhnmoYdEJ0+JCw==')
      expect(identity['ephemeral_public_signature_key']).to eq('Xh3i0xDTpr3HXtB2Q517QKv3azNzXLLXMdJDTSH4bd4=')
      expect(identity['ephemeral_private_signature_key']).to eq('jEDT4wQCc1DFwodXNPHFClndTPnFuFmXhBt+isKU4ZpeHeLTENOmvcde0HZDnXtAq/drM3Ncstcx0kNNIfht3g==')
      expect(identity['user_secret']).to eq('7FSf/n0e76QT3s0DkvetRVVJhXZGEjOxj5EWAFexvjI=')
    end

    it 'a valid provisional identity' do
      identity = Tanker::Identity.deserialize(@provisional_identity)

      expect(identity['trustchain_id']).to eq(@app[:id])
      expect(identity['target']).to eq('email')
      expect(identity['value']).to eq(@user_email)
      expect(identity['public_signature_key']).to eq('W7QEQBu9FXcXIpOgq62tPwBiyFAbpT1rAruD0h/NrTA=')
      expect(identity['private_signature_key']).to eq('UmnYuvdTaLYG0a+JaDpY6ojw4/2Ll8zsmramVC4fuqRbtARAG70Vdxcik6Crra0/AGLIUBulPWsCu4PSH82tMA==')
      expect(identity['public_encryption_key']).to eq('/2j4dI3r8PlvCN3uW4HhA5wBtMKOcACd38K6N0q+mFU=')
      expect(identity['private_encryption_key']).to eq('4QB5TWmvcBrgeyDDLhULINU6tbqAOEQ8v9pjDkPcybA=')
    end

    it 'a valid public identity' do
      identity = Tanker::Identity.deserialize(@public_identity)

      expect(identity['trustchain_id']).to eq(@app[:id])
      expect(identity['target']).to eq('user')
      expect(identity['value']).to eq(@hashed_user_id)
    end

    it 'a valid public provisional identity' do
      identity = Tanker::Identity.deserialize(@public_provisional_identity)

      expect(identity['trustchain_id']).to eq(@app[:id])
      expect(identity['target']).to eq('email')
      expect(identity['value']).to eq(@user_email)
      expect(identity['public_signature_key']).to eq('W7QEQBu9FXcXIpOgq62tPwBiyFAbpT1rAruD0h/NrTA=')
      expect(identity['public_encryption_key']).to eq('/2j4dI3r8PlvCN3uW4HhA5wBtMKOcACd38K6N0q+mFU=')
    end
  end

  describe 'argument checking' do
    def corrupt(arr, pos, value)
      arr.dup.tap { |a| a[pos] = value }
    end

    def truncate_b64(arr, pos, bytesize)
      arr.dup.tap { |a| a[pos] = Base64.strict_encode64(Base64.strict_decode64(a[pos])[0..(bytesize - 1)]) }
    end

    def delete_key(identity, key)
      Tanker::Identity.serialize(
        Tanker::Identity.deserialize(identity).tap { |h| h.delete(key) }
      )
    end

    before(:all) do
      @not_string = 1234
      @not_b64 = '&:,?'
    end

    it "raises if invalid argument when creating a permanent identity" do
      args = [@app[:id], @app[:secret], @user_id]
      expect { Tanker::Identity.create_identity(*corrupt(args, 0, @not_string)) }.to raise_exception(TypeError)
      expect { Tanker::Identity.create_identity(*corrupt(args, 1, @not_string)) }.to raise_exception(TypeError)
      expect { Tanker::Identity.create_identity(*corrupt(args, 2, @not_string)) }.to raise_exception(TypeError)
      expect { Tanker::Identity.create_identity(*corrupt(args, 0, @not_b64)) }.to raise_exception(ArgumentError)
      expect { Tanker::Identity.create_identity(*corrupt(args, 1, @not_b64)) }.to raise_exception(ArgumentError)
      expect { Tanker::Identity.create_identity(*truncate_b64(args, 0, 16)) }.to raise_exception(ArgumentError)
      expect { Tanker::Identity.create_identity(*truncate_b64(args, 1, 32)) }.to raise_exception(ArgumentError)
    end

    it 'raises if app id and app secret mismatch when creating a permanent identity' do
      mismatching_app_id = "rB0/yEJWCUVYRtDZLtXaJqtneXQOsCSKrtmWw+V+ysc="
      args = [mismatching_app_id, @app[:secret], @user_id]
      expect { Tanker::Identity.create_identity(*args) }.to raise_exception(ArgumentError)
    end

    it 'raises if invalid argument when creating a provisional identity' do
      args = [@app[:id], @user_email]
      expect { Tanker::Identity.create_provisional_identity(*corrupt(args, 0, @not_string)) }.to raise_exception(TypeError)
      expect { Tanker::Identity.create_provisional_identity(*corrupt(args, 1, @not_string)) }.to raise_exception(TypeError)
      expect { Tanker::Identity.create_provisional_identity(*corrupt(args, 0, @not_b64)) }.to raise_exception(ArgumentError)
      expect { Tanker::Identity.create_provisional_identity(*truncate_b64(args, 0, 16)) }.to raise_exception(ArgumentError)
    end

    it 'raises if invalid argument when getting a public identity' do
      expect { Tanker::Identity.get_public_identity(@not_string) }.to raise_exception(TypeError)
      expect { Tanker::Identity.get_public_identity(@not_b64) }.to raise_exception(ArgumentError)

      corrupted_identity = delete_key(@permanent_identity, 'value')
      expect { Tanker::Identity.get_public_identity(corrupted_identity) }.to raise_exception(ArgumentError)
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

    def assert_signature(identity, app_public_key)
      signed_data = Base64.decode64(identity['ephemeral_public_signature_key']) +
                    Base64.decode64(identity['value'])

      signature = Base64.decode64(identity['delegation_signature'])
      public_key = Base64.decode64(app_public_key)

      expect {
        Tanker::Crypto.verify_sign_detached(signed_data, signature, public_key)
      }.not_to raise_exception # no Tanker::Crypto::InvalidSignature
    end

    before(:all) do
      @b64_identity = Tanker::Identity.create_identity(@app[:id], @app[:secret], @user_id)
      @identity = Tanker::Identity.deserialize(@b64_identity)
    end

    it 'returns a permanent identity' do
      expect(@identity.keys.sort).to eq ['delegation_signature', 'ephemeral_private_signature_key', 'ephemeral_public_signature_key', 'target', 'trustchain_id', 'user_secret', 'value']
      expect(@identity['trustchain_id']).to eq @app[:id]
      expect(@identity['target']).to eq 'user'
      assert_user_secret(@identity)
      assert_signature(@identity, @app[:public_key])
    end

    it 'returns a public identity from a permanent identity' do
      b64_public_identity = Tanker::Identity.get_public_identity(@b64_identity)
      public_identity = Tanker::Identity.deserialize(b64_public_identity)
      expect(public_identity.keys.sort).to eq ['target', 'trustchain_id', 'value']
      expect(public_identity['trustchain_id']).to eq @app[:id]
      expect(public_identity['target']).to eq 'user'
      expect(public_identity['value']).to eq @identity['value']
    end
  end

  describe 'provisional identity' do
    before(:all) do
      @b64_identity = Tanker::Identity.create_provisional_identity(@app[:id], @user_email)
      @identity = Tanker::Identity.deserialize(@b64_identity)
    end

    it 'returns a provisional identity' do
      expect(@identity.keys.sort).to eq ['private_encryption_key', 'private_signature_key', 'public_encryption_key', 'public_signature_key', 'target', 'trustchain_id', 'value']
      expect(@identity['trustchain_id']).to eq @app[:id]
      expect(@identity['target']).to eq 'email'
      expect(@identity['value']).to eq @user_email
    end

    it 'returns a public identity from a provisional identity' do
      b64_public_identity = Tanker::Identity.get_public_identity(@b64_identity)
      public_identity = Tanker::Identity.deserialize(b64_public_identity)
      expect(public_identity.keys.sort).to eq ['public_encryption_key', 'public_signature_key', 'target', 'trustchain_id', 'value']
      expect(public_identity['trustchain_id']).to eq @app[:id]
      expect(public_identity['target']).to eq 'email'
      expect(public_identity['value']).to eq @user_email
      expect(public_identity['public_encryption_key']).to eq @identity['public_encryption_key']
      expect(public_identity['public_signature_key']).to eq @identity['public_signature_key']
    end
  end
end
