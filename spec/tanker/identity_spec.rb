# frozen_string_literal: true

require 'base64'

RSpec.describe Tanker::Identity do
  before(:all) do
    # Note: vectors below were generated with the Javascript SDK. We keep it to
    #       check Javascript and Ruby code are interoperable
    @app = test_app
    @user_id = 'b_eich'
    @user_email = 'brendan.eich@tanker.io'
    @user_phone = '+33611223344'
    @hashed_email = '0u2c8w8EIZWT2FzRN/yyM5qIbEGYTNDT5SkWVBu20Qo='
    @hashed_user_id = 'RDa0eq4XNuj5tV7hdapjOxhmheTh4QBDNpy4Svy9Xok='
    @permanent_identity = 'eyJ0cnVzdGNoYWluX2lkIjoidHBveHlOemgwaFU5RzJpOWFnTXZIeXlkK3BPNnpHQ2pPOUJmaHJDTGpkND0iLCJ0YXJnZXQiOiJ1c2VyIiwidmFsdWUiOiJSRGEwZXE0WE51ajV0VjdoZGFwak94aG1oZVRoNFFCRE5weTRTdnk5WG9rPSIsImRlbGVnYXRpb25fc2lnbmF0dXJlIjoiVTlXUW9sQ3ZSeWpUOG9SMlBRbWQxV1hOQ2kwcW1MMTJoTnJ0R2FiWVJFV2lyeTUya1d4MUFnWXprTHhINmdwbzNNaUE5cisremhubW9ZZEVKMCtKQ3c9PSIsImVwaGVtZXJhbF9wdWJsaWNfc2lnbmF0dXJlX2tleSI6IlhoM2kweERUcHIzSFh0QjJRNTE3UUt2M2F6TnpYTExYTWRKRFRTSDRiZDQ9IiwiZXBoZW1lcmFsX3ByaXZhdGVfc2lnbmF0dXJlX2tleSI6ImpFRFQ0d1FDYzFERndvZFhOUEhGQ2xuZFRQbkZ1Rm1YaEJ0K2lzS1U0WnBlSGVMVEVOT212Y2RlMEhaRG5YdEFxL2RyTTNOY3N0Y3gwa05OSWZodDNnPT0iLCJ1c2VyX3NlY3JldCI6IjdGU2YvbjBlNzZRVDNzMERrdmV0UlZWSmhYWkdFak94ajVFV0FGZXh2akk9In0='
    @provisional_identity = 'eyJ0cnVzdGNoYWluX2lkIjoidHBveHlOemgwaFU5RzJpOWFnTXZIeXlkK3BPNnpHQ2pPOUJmaHJDTGpkND0iLCJ0YXJnZXQiOiJlbWFpbCIsInZhbHVlIjoiYnJlbmRhbi5laWNoQHRhbmtlci5pbyIsInB1YmxpY19lbmNyeXB0aW9uX2tleSI6Ii8yajRkSTNyOFBsdkNOM3VXNEhoQTV3QnRNS09jQUNkMzhLNk4wcSttRlU9IiwicHJpdmF0ZV9lbmNyeXB0aW9uX2tleSI6IjRRQjVUV212Y0JyZ2V5RERMaFVMSU5VNnRicUFPRVE4djlwakRrUGN5YkE9IiwicHVibGljX3NpZ25hdHVyZV9rZXkiOiJXN1FFUUJ1OUZYY1hJcE9ncTYydFB3Qml5RkFicFQxckFydUQwaC9OclRBPSIsInByaXZhdGVfc2lnbmF0dXJlX2tleSI6IlVtbll1dmRUYUxZRzBhK0phRHBZNm9qdzQvMkxsOHpzbXJhbVZDNGZ1cVJidEFSQUc3MFZkeGNpazZDcnJhMC9BR0xJVUJ1bFBXc0N1NFBTSDgydE1BPT0ifQ=='
    @public_identity = 'eyJ0cnVzdGNoYWluX2lkIjoidHBveHlOemgwaFU5RzJpOWFnTXZIeXlkK3BPNnpHQ2pPOUJmaHJDTGpkND0iLCJ0YXJnZXQiOiJ1c2VyIiwidmFsdWUiOiJSRGEwZXE0WE51ajV0VjdoZGFwak94aG1oZVRoNFFCRE5weTRTdnk5WG9rPSJ9'
    @old_public_provisional_identity = 'eyJ0cnVzdGNoYWluX2lkIjoidHBveHlOemgwaFU5RzJpOWFnTXZIeXlkK3BPNnpHQ2pPOUJmaHJDTGpkND0iLCJ0YXJnZXQiOiJlbWFpbCIsInZhbHVlIjoiYnJlbmRhbi5laWNoQHRhbmtlci5pbyIsInB1YmxpY19lbmNyeXB0aW9uX2tleSI6Ii8yajRkSTNyOFBsdkNOM3VXNEhoQTV3QnRNS09jQUNkMzhLNk4wcSttRlU9IiwicHVibGljX3NpZ25hdHVyZV9rZXkiOiJXN1FFUUJ1OUZYY1hJcE9ncTYydFB3Qml5RkFicFQxckFydUQwaC9OclRBPSJ9'
    @public_provisional_identity = 'eyJ0cnVzdGNoYWluX2lkIjoidHBveHlOemgwaFU5RzJpOWFnTXZIeXlkK3BPNnpHQ2pPOUJmaHJDTGpkND0iLCJ0YXJnZXQiOiJoYXNoZWRfZW1haWwiLCJ2YWx1ZSI6IjB1MmM4dzhFSVpXVDJGelJOL3l5TTVxSWJFR1lUTkRUNVNrV1ZCdTIwUW89IiwicHVibGljX2VuY3J5cHRpb25fa2V5IjoiLzJqNGRJM3I4UGx2Q04zdVc0SGhBNXdCdE1LT2NBQ2QzOEs2TjBxK21GVT0iLCJwdWJsaWNfc2lnbmF0dXJlX2tleSI6Ilc3UUVRQnU5RlhjWElwT2dxNjJ0UHdCaXlGQWJwVDFyQXJ1RDBoL05yVEE9In0='
    @phone_number_provisional_identity = 'eyJ0cnVzdGNoYWluX2lkIjoidHBveHlOemgwaFU5RzJpOWFnTXZIeXlkK3BPNnpHQ2pPOUJmaHJDTGpkND0iLCJ0YXJnZXQiOiJwaG9uZV9udW1iZXIiLCJ2YWx1ZSI6IiszMzYxMTIyMzM0NCIsInB1YmxpY19lbmNyeXB0aW9uX2tleSI6Im42bTlYNUxmMFpuYXo4ZjArc2NoTElCTm0rcGlQaG5zWXZBdlh3MktFQXc9IiwicHJpdmF0ZV9lbmNyeXB0aW9uX2tleSI6InRWVFM5bkh4cjJNZFZ1VFI1Y2x3dzBFWGJ3aXM4SGl4Z1BJTmJRSngxVTQ9IiwicHVibGljX3NpZ25hdHVyZV9rZXkiOiJqcklEaWdTQ25BaTNHbDltSUFTbEFpU2hLQzdkQkxGVVpQOUN4TEdzYkg4PSIsInByaXZhdGVfc2lnbmF0dXJlX2tleSI6IlFIcWNMcjhicjZNM2JQblFtUWczcStxSENycDA1RGJjQnBMUGFUWlkwYTZPc2dPS0JJS2NDTGNhWDJZZ0JLVUNKS0VvTHQwRXNWUmsvMExFc2F4c2Z3PT0ifQ=='
    @phone_number_public_provisional_identity = 'eyJ0cnVzdGNoYWluX2lkIjoidHBveHlOemgwaFU5RzJpOWFnTXZIeXlkK3BPNnpHQ2pPOUJmaHJDTGpkND0iLCJ0YXJnZXQiOiJoYXNoZWRfcGhvbmVfbnVtYmVyIiwidmFsdWUiOiJKZWFpUUFoOHg3amNpb1UybTRpaHkrQ3NISmx5Vys0VlZTU3M1U0hGVVR3PSIsInB1YmxpY19lbmNyeXB0aW9uX2tleSI6Im42bTlYNUxmMFpuYXo4ZjArc2NoTElCTm0rcGlQaG5zWXZBdlh3MktFQXc9IiwicHVibGljX3NpZ25hdHVyZV9rZXkiOiJqcklEaWdTQ25BaTNHbDltSUFTbEFpU2hLQzdkQkxGVVpQOUN4TEdzYkg4PSJ9'
  end

  describe 'format' do
    it 'create_identity serializes all fields and in the right order' do
      b64_identity = Tanker::Identity.create_identity(@app[:id], @app[:secret], @user_id)
      identity = Tanker::Identity.deserialize(b64_identity)
      expect(identity.keys).to eq(%w[trustchain_id target value delegation_signature ephemeral_public_signature_key ephemeral_private_signature_key user_secret])
    end

    it 'get_public_identity on a permanent identity serializes all fields and in the right order' do
      b64_full_identity = Tanker::Identity.create_identity(@app[:id], @app[:secret], @user_id)
      b64_identity = Tanker::Identity.get_public_identity(b64_full_identity)
      identity = Tanker::Identity.deserialize(b64_identity)
      expect(identity.keys).to eq(%w[trustchain_id target value])
    end

    it 'create_provisional_identity serializes all fields and in the right order' do
      b64_identity = Tanker::Identity.create_provisional_identity(@app[:id], 'email', 'brendan.eich@tanker.io')
      identity = Tanker::Identity.deserialize(b64_identity)
      expect(identity.keys).to eq(%w[trustchain_id target value public_encryption_key private_encryption_key public_signature_key private_signature_key])
    end

    it 'get_public_identity on a provisional identity serializes all fields and in the right order' do
      b64_full_identity = Tanker::Identity.create_provisional_identity(@app[:id], 'email', 'brendan.eich@tanker.io')
      b64_identity = Tanker::Identity.get_public_identity(b64_full_identity)
      identity = Tanker::Identity.deserialize(b64_identity)
      expect(identity.keys).to eq(%w[trustchain_id target value public_encryption_key public_signature_key])
    end

    it 'matches the frozen secret permanent identity test vector' do
      identity_obj = {
        trustchain_id: 'tpoxyNzh0hU9G2i9agMvHyyd+pO6zGCjO9BfhrCLjd4=',
        target: 'user',
        value: @hashed_user_id,
        delegation_signature: 'U9WQolCvRyjT8oR2PQmd1WXNCi0qmL12hNrtGabYREWiry52kWx1AgYzkLxH6gpo3MiA9r++zhnmoYdEJ0+JCw==',
        ephemeral_public_signature_key: 'Xh3i0xDTpr3HXtB2Q517QKv3azNzXLLXMdJDTSH4bd4=',
        ephemeral_private_signature_key:
          'jEDT4wQCc1DFwodXNPHFClndTPnFuFmXhBt+isKU4ZpeHeLTENOmvcde0HZDnXtAq/drM3Ncstcx0kNNIfht3g==',
        user_secret: '7FSf/n0e76QT3s0DkvetRVVJhXZGEjOxj5EWAFexvjI=',
      }
      identity = Tanker::Identity.serialize(identity_obj)
      expect(identity).to eq(@permanent_identity)
    end

    it 'matches the frozen public permanent identity test vector' do
      identity_obj = {
        trustchain_id: 'tpoxyNzh0hU9G2i9agMvHyyd+pO6zGCjO9BfhrCLjd4=',
        target: 'user',
        value: @hashed_user_id
      }
      identity = Tanker::Identity.serialize(identity_obj)
      expect(identity).to eq(@public_identity)
    end

    it 'matches the frozen secret provisional identity test vector' do
      identity_obj = {
        trustchain_id: 'tpoxyNzh0hU9G2i9agMvHyyd+pO6zGCjO9BfhrCLjd4=',
        target: 'email',
        value: 'brendan.eich@tanker.io',
        public_encryption_key: '/2j4dI3r8PlvCN3uW4HhA5wBtMKOcACd38K6N0q+mFU=',
        private_encryption_key: '4QB5TWmvcBrgeyDDLhULINU6tbqAOEQ8v9pjDkPcybA=',
        public_signature_key: 'W7QEQBu9FXcXIpOgq62tPwBiyFAbpT1rAruD0h/NrTA=',
        private_signature_key: 'UmnYuvdTaLYG0a+JaDpY6ojw4/2Ll8zsmramVC4fuqRbtARAG70Vdxcik6Crra0/AGLIUBulPWsCu4PSH82tMA==',
      }
      identity = Tanker::Identity.serialize(identity_obj)
      expect(identity).to eq(@provisional_identity)
    end

    it 'matches the non-hashed frozen public provisional identity test vector' do
      identity_obj = {
        trustchain_id: 'tpoxyNzh0hU9G2i9agMvHyyd+pO6zGCjO9BfhrCLjd4=',
        target: 'email',
        value: 'brendan.eich@tanker.io',
        public_encryption_key: '/2j4dI3r8PlvCN3uW4HhA5wBtMKOcACd38K6N0q+mFU=',
        public_signature_key: 'W7QEQBu9FXcXIpOgq62tPwBiyFAbpT1rAruD0h/NrTA=',
      }
      identity = Tanker::Identity.serialize(identity_obj)
      expect(identity).to eq(@old_public_provisional_identity)
    end

    it 'matches the hashed frozen public provisional identity test vector' do
      identity_obj = {
        trustchain_id: 'tpoxyNzh0hU9G2i9agMvHyyd+pO6zGCjO9BfhrCLjd4=',
        target: 'hashed_email',
        value: @hashed_email,
        public_encryption_key: '/2j4dI3r8PlvCN3uW4HhA5wBtMKOcACd38K6N0q+mFU=',
        public_signature_key: 'W7QEQBu9FXcXIpOgq62tPwBiyFAbpT1rAruD0h/NrTA=',
      }
      identity = Tanker::Identity.serialize(identity_obj)
      expect(identity).to eq(@public_provisional_identity)
    end

    it 'can upgrade to a hashed public provisional identity' do
      expect(Tanker::Identity.upgrade_identity(@old_public_provisional_identity)).to eq(@public_provisional_identity)
    end
  end

  describe 'parse' do
    it 'parses a valid permanent identity' do
      identity = Tanker::Identity.deserialize(@permanent_identity)

      expect(identity['trustchain_id']).to eq(@app[:id])
      expect(identity['target']).to eq('user')
      expect(identity['value']).to eq(@hashed_user_id)
      expect(identity['delegation_signature']).to eq('U9WQolCvRyjT8oR2PQmd1WXNCi0qmL12hNrtGabYREWiry52kWx1AgYzkLxH6gpo3MiA9r++zhnmoYdEJ0+JCw==')
      expect(identity['ephemeral_public_signature_key']).to eq('Xh3i0xDTpr3HXtB2Q517QKv3azNzXLLXMdJDTSH4bd4=')
      expect(identity['ephemeral_private_signature_key']).to eq('jEDT4wQCc1DFwodXNPHFClndTPnFuFmXhBt+isKU4ZpeHeLTENOmvcde0HZDnXtAq/drM3Ncstcx0kNNIfht3g==')
      expect(identity['user_secret']).to eq('7FSf/n0e76QT3s0DkvetRVVJhXZGEjOxj5EWAFexvjI=')
    end

    it 'parses a valid provisional identity' do
      identity = Tanker::Identity.deserialize(@provisional_identity)

      expect(identity['trustchain_id']).to eq(@app[:id])
      expect(identity['target']).to eq('email')
      expect(identity['value']).to eq(@user_email)
      expect(identity['public_signature_key']).to eq('W7QEQBu9FXcXIpOgq62tPwBiyFAbpT1rAruD0h/NrTA=')
      expect(identity['private_signature_key']).to eq('UmnYuvdTaLYG0a+JaDpY6ojw4/2Ll8zsmramVC4fuqRbtARAG70Vdxcik6Crra0/AGLIUBulPWsCu4PSH82tMA==')
      expect(identity['public_encryption_key']).to eq('/2j4dI3r8PlvCN3uW4HhA5wBtMKOcACd38K6N0q+mFU=')
      expect(identity['private_encryption_key']).to eq('4QB5TWmvcBrgeyDDLhULINU6tbqAOEQ8v9pjDkPcybA=')
    end

    it 'parses a valid public identity' do
      identity = Tanker::Identity.deserialize(@public_identity)

      expect(identity['trustchain_id']).to eq(@app[:id])
      expect(identity['target']).to eq('user')
      expect(identity['value']).to eq(@hashed_user_id)
    end

    it 'parses a valid non-hashed public provisional identity' do
      identity = Tanker::Identity.deserialize(@old_public_provisional_identity)

      expect(identity['trustchain_id']).to eq(@app[:id])
      expect(identity['target']).to eq('email')
      expect(identity['value']).to eq(@user_email)
      expect(identity['public_signature_key']).to eq('W7QEQBu9FXcXIpOgq62tPwBiyFAbpT1rAruD0h/NrTA=')
      expect(identity['public_encryption_key']).to eq('/2j4dI3r8PlvCN3uW4HhA5wBtMKOcACd38K6N0q+mFU=')
    end

    it 'parses a valid hashed public provisional identity' do
      identity = Tanker::Identity.deserialize(@public_provisional_identity)

      expect(identity['trustchain_id']).to eq(@app[:id])
      expect(identity['target']).to eq('hashed_email')
      expect(identity['value']).to eq(@hashed_email)
      expect(identity['public_signature_key']).to eq('W7QEQBu9FXcXIpOgq62tPwBiyFAbpT1rAruD0h/NrTA=')
      expect(identity['public_encryption_key']).to eq('/2j4dI3r8PlvCN3uW4HhA5wBtMKOcACd38K6N0q+mFU=')
    end

    it 'parses a valid phone_number provisional identity' do
      identity = Tanker::Identity.deserialize(@phone_number_provisional_identity)

      expect(identity['trustchain_id']).to eq(@app[:id])
      expect(identity['target']).to eq('phone_number')
      expect(identity['value']).to eq(@user_phone)
      expect(identity['public_signature_key']).to eq('jrIDigSCnAi3Gl9mIASlAiShKC7dBLFUZP9CxLGsbH8=')
      expect(identity['private_signature_key']).to eq('QHqcLr8br6M3bPnQmQg3q+qHCrp05DbcBpLPaTZY0a6OsgOKBIKcCLcaX2YgBKUCJKEoLt0EsVRk/0LEsaxsfw==')
      expect(identity['public_encryption_key']).to eq('n6m9X5Lf0Znaz8f0+schLIBNm+piPhnsYvAvXw2KEAw=')
      expect(identity['private_encryption_key']).to eq('tVTS9nHxr2MdVuTR5clww0EXbwis8HixgPINbQJx1U4=')
    end

    it 'parses a valid phone_number public provisional identity' do
      private_identity = Tanker::Identity.deserialize(@phone_number_provisional_identity)
      identity = Tanker::Identity.deserialize(@phone_number_public_provisional_identity)
      expect(Tanker::Identity.get_public_identity(@phone_number_provisional_identity)).to eq(@phone_number_public_provisional_identity)

      hashed_phone_number = Tanker::Crypto.hashed_provisional_value(@user_phone, private_identity['private_signature_key'])

      expect(identity['trustchain_id']).to eq(@app[:id])
      expect(identity['target']).to eq('hashed_phone_number')
      expect(identity['value']).to eq(hashed_phone_number)
      expect(identity['public_signature_key']).to eq('jrIDigSCnAi3Gl9mIASlAiShKC7dBLFUZP9CxLGsbH8=')
      expect(identity['public_encryption_key']).to eq('n6m9X5Lf0Znaz8f0+schLIBNm+piPhnsYvAvXw2KEAw=')
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
      args = [@app[:id], 'email', @user_email]
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
      hashed_user_id = Base64.decode64(identity['value'])
      user_secret = Base64.decode64(identity['user_secret'])
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

      expect do
        Tanker::Crypto.verify_sign_detached(signed_data, signature, public_key)
      end.not_to raise_exception # no Tanker::Crypto::InvalidSignature
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
      @b64_email_identity = Tanker::Identity.create_provisional_identity(@app[:id], 'email', @user_email)
      @b64_phone_number_identity = Tanker::Identity.create_provisional_identity(@app[:id], 'phone_number', @user_phone)
      @email_identity = Tanker::Identity.deserialize(@b64_email_identity)
      @phone_number_identity = Tanker::Identity.deserialize(@b64_phone_number_identity)
    end

    it 'cannot create a provisional identity with an invalid target' do
      expect do
        Tanker::Identity.create_provisional_identity(@app[:id], 'meme pas en rêve', 'whatever')
      end.to raise_exception ArgumentError
    end

    it 'returns an email provisional identity' do
      expect(@email_identity.keys.sort).to eq ['private_encryption_key', 'private_signature_key', 'public_encryption_key', 'public_signature_key', 'target', 'trustchain_id', 'value']
      expect(@email_identity['trustchain_id']).to eq @app[:id]
      expect(@email_identity['target']).to eq 'email'
      expect(@email_identity['value']).to eq @user_email
    end

    it 'returns a public identity from a provisional identity' do
      b64_public_identity = Tanker::Identity.get_public_identity(@b64_email_identity)
      public_identity = Tanker::Identity.deserialize(b64_public_identity)
      expect(public_identity.keys.sort).to eq ['public_encryption_key', 'public_signature_key', 'target', 'trustchain_id', 'value']
      expect(public_identity['trustchain_id']).to eq @app[:id]
      expect(public_identity['target']).to eq 'hashed_email'
      expect(public_identity['value']).to eq @hashed_email
      expect(public_identity['public_encryption_key']).to eq @email_identity['public_encryption_key']
      expect(public_identity['public_signature_key']).to eq @email_identity['public_signature_key']
    end

    it 'returns a phone_number provisional identity' do
      expect(@phone_number_identity.keys.sort).to eq ['private_encryption_key', 'private_signature_key', 'public_encryption_key', 'public_signature_key', 'target', 'trustchain_id', 'value']
      expect(@phone_number_identity['trustchain_id']).to eq @app[:id]
      expect(@phone_number_identity['target']).to eq 'phone_number'
      expect(@phone_number_identity['value']).to eq @user_phone
    end

    it 'returns a public identity from a provisional identity' do
      b64_public_identity = Tanker::Identity.get_public_identity(@b64_phone_number_identity)
      public_identity = Tanker::Identity.deserialize(b64_public_identity)

      hashed_phone_number = Tanker::Crypto.hashed_provisional_value(@user_phone, @phone_number_identity['private_signature_key'])

      expect(public_identity.keys.sort).to eq ['public_encryption_key', 'public_signature_key', 'target', 'trustchain_id', 'value']
      expect(public_identity['trustchain_id']).to eq @app[:id]
      expect(public_identity['target']).to eq 'hashed_phone_number'
      expect(public_identity['value']).to eq hashed_phone_number
      expect(public_identity['public_encryption_key']).to eq @phone_number_identity['public_encryption_key']
      expect(public_identity['public_signature_key']).to eq @phone_number_identity['public_signature_key']
    end
  end
end
