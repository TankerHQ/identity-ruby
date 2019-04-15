require 'bundler/setup'
require 'tanker-identity'

module Helpers
  # Note: this was generated with the Javascript SDK. We keep it to check Javascript
  # and Ruby code are interoperable
  def test_trustchain
    {
      id: "tpoxyNzh0hU9G2i9agMvHyyd+pO6zGCjO9BfhrCLjd4=",
      private_key: "cTMoGGUKhwN47ypq4xAXAtVkNWeyUtMltQnYwJhxWYSvqjPVGmXd2wwa7y17QtPTZhn8bxb015CZC/e4ZI7+MQ==",
      public_key: "r6oz1Rpl3dsMGu8te0LT02YZ/G8W9NeQmQv3uGSO/jE=",
    }
  end

  def corrupt_binary(binary)
    binary.dup.tap { |b| b.setbyte(0, (b.getbyte(0) + 1) % 256) }
  end
end

RSpec.configure do |config|
  # Enable flags like --only-failures and --next-failure
  config.example_status_persistence_file_path = '.rspec_status'

  # Disable RSpec exposing methods globally on `Module` and `main`
  config.disable_monkey_patching!

  config.expect_with :rspec do |c|
    c.syntax = :expect
  end

  config.include Helpers
end
