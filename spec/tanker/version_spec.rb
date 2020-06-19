# frozen_string_literal: true
RSpec.describe Tanker do
  it 'has a version number' do
    expect(Tanker::Identity::VERSION).to be_a String
  end
end
