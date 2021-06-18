module Tanker
  module Identity
    VERSION = '0.0.1'
  end

  def self.const_missing(name)
    super unless name == :VERSION
    warn "DEPRECATION WARNING: Using `Tanker::VERSION` is deprecated in favor of `Tanker::Identity::VERSION`"
    Tanker::Identity::VERSION
  end
end
