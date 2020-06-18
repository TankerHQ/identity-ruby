
lib = File.expand_path("../lib", __FILE__)
$LOAD_PATH.unshift(lib) unless $LOAD_PATH.include?(lib)
require "tanker/identity/version"

Gem::Specification.new do |spec|
  spec.name          = "tanker-identity"
  spec.version       = Tanker::Identity::VERSION
  spec.authors       = ["Tanker Team"]
  spec.email         = ["contact@tanker.io"]

  spec.summary       = %q{Tanker identity management library packaged as a gem}
  spec.description   = %q{Building blocks to add Tanker identity management to your application server}
  spec.homepage      = "https://github.com/TankerHQ/identity-ruby"

  spec.license       = "Apache-2.0"

  # Prevent pushing this gem to RubyGems.org. To allow pushes either set the 'allowed_push_host'
  # to allow pushing to a single host or delete this section to allow pushing to any host.
  if spec.respond_to?(:metadata)
    spec.metadata["allowed_push_host"] = "TODO: Set to 'http://mygemserver.com'"

    spec.metadata["homepage_uri"] = spec.homepage
    # spec.metadata["source_code_uri"] = "TODO: Put your gem's public repo URL here."
    # spec.metadata["changelog_uri"] = "TODO: Put your gem's CHANGELOG.md URL here."
  else
    raise "RubyGems 2.0 or newer is required to protect against " \
      "public gem pushes."
  end

  # Specify which files should be added to the gem when it is released.
  spec.files = Dir["README.md", "LICENSE", "lib/**/*"]

  spec.require_paths = ["lib"]

  spec.add_runtime_dependency "rbnacl", "~> 7.0"
  spec.required_ruby_version = ">= 2.5"

  spec.add_development_dependency "bundler", "~> 2.0"
  spec.add_development_dependency "bundler-audit", "~> 0.7"
  spec.add_development_dependency "rake", "~> 13.0"
  spec.add_development_dependency "rspec", "~> 3.0"
  spec.add_development_dependency "simplecov"
  spec.add_development_dependency "codecov"
end
