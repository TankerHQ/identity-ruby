# typed: false
# frozen_string_literal: true
RSpec.describe Tanker do
  it 'has a version number' do
    expect(Tanker::VERSION).not_to be nil
  end
end
