
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
  spec.homepage      = "https://tanker.io"
  spec.license       = "Apache-2.0"
  spec.required_ruby_version = Gem::Requirement.new('>= 2.5.0')

  spec.metadata["homepage_uri"] = spec.homepage
  spec.metadata["source_code_uri"] = "https://github.com/TankerHQ/identity-ruby"
  spec.metadata["changelog_uri"] = "https://docs.tanker.io/latest/release-notes/identity/ruby"

  # Specify which files should be added to the gem when it is released.
  spec.files = Dir["README.md", "LICENSE", "lib/**/*"]

  spec.require_paths = ["lib"]

  spec.add_runtime_dependency "rbnacl", "~> 7.0"

  spec.add_development_dependency "bundler", "~> 2.0"
  spec.add_development_dependency "bundler-audit", "~> 0.7"
  spec.add_development_dependency "rake", "~> 13.0"
  spec.add_development_dependency "rspec", "~> 3.0"
  spec.add_development_dependency 'rubygems-tasks', '~> 0.2.5'
  spec.add_development_dependency "simplecov"
  spec.add_development_dependency "simplecov-cobertura"
end
