# coding: utf-8
lib = File.expand_path("../lib", __FILE__)
$LOAD_PATH.unshift(lib) unless $LOAD_PATH.include?(lib)
require "marloss/version"

Gem::Specification.new do |spec|
  spec.name          = "marloss"
  spec.version       = Marloss::VERSION
  spec.authors       = ["Jacopo Scrinzi"]
  spec.email         = "scrinzi.jcopo@gmail.com"

  spec.summary       = %q{AWS DynamoDB based Locking}
  spec.description   = %q{Distributed locking using AWS DynamoDB}
  spec.homepage      = "https://github.com/eredi93/marloss"
  spec.license       = "MIT"

  spec.files         = `git ls-files -z`.split("\x0").reject { |f| f.match(%r{^(test|spec|features)/}) }
  spec.require_paths = %w(lib)

  spec.add_dependency "aws-sdk-dynamodb", "~> 1.2"

  spec.add_development_dependency "bundler"
  spec.add_development_dependency "rake"
  spec.add_development_dependency "rspec"
end
