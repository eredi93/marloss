# frozen_string_literal: true

lib = File.expand_path("lib", __dir__)
$LOAD_PATH.unshift(lib) unless $LOAD_PATH.include?(lib)
require "marloss/version"

files = `git ls-files -z`.split("\x0")
  .reject { |f| f.match(%r{^(test|spec|features)/}) }

Gem::Specification.new do |spec|
  spec.name          = "marloss"
  spec.version       = Marloss::VERSION
  spec.authors       = ["Jacopo Scrinzi"]
  spec.email         = "scrinzi.jcopo@gmail.com"

  spec.summary       = "AWS DynamoDB based Locking"
  spec.description   = "Distributed locking using AWS DynamoDB"
  spec.homepage      = "https://github.com/eredi93/marloss"
  spec.license       = "MIT"

  spec.files         = files
  spec.require_paths = %w[lib]

  spec.add_dependency "aws-sdk-dynamodb", "~> 1.11"

  spec.add_development_dependency "bundler", "~> 1"
  spec.add_development_dependency "gem-release", "~> 2.0"
  spec.add_development_dependency "rake", "~> 12.3"
  spec.add_development_dependency "rspec", "~> 3.8"
  spec.add_development_dependency "rubocop", "~> 0.58"
end
