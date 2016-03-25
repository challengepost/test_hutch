# coding: utf-8
lib = File.expand_path('../lib', __FILE__)
$LOAD_PATH.unshift(lib) unless $LOAD_PATH.include?(lib)
require 'test_hutch/version'

Gem::Specification.new do |spec|
  spec.name          = "test_hutch"
  spec.version       = TestHutch::VERSION
  spec.authors       = ["midu", "niuage"]
  spec.email         = ["niuage@gmail.com"]

  spec.summary       = %q{Makes it easy to mock Hutch in tests.}
  spec.description   = %q{TestHutch makes it easy to test code depending on RabbitMQ and Hutch, providing 3 different modes, inline, fake, and disabled.}
  spec.homepage      = "https://github.com/challengepost/test_hutch"

  spec.files         = `git ls-files -z`.split("\x0").reject { |f| f.match(%r{^(test|spec|features)/}) }
  spec.bindir        = "exe"
  spec.executables   = spec.files.grep(%r{^exe/}) { |f| File.basename(f) }
  spec.require_paths = ["lib"]

  spec.add_development_dependency "bundler", "~> 1.9"
  spec.add_development_dependency "rake", "~> 10.0"
  spec.add_development_dependency "rspec"
end
