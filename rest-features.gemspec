# coding: utf-8
lib = File.expand_path('../lib', __FILE__)
$LOAD_PATH.unshift(lib) unless $LOAD_PATH.include?(lib)
require 'rest/features/version'

Gem::Specification.new do |spec|
  spec.name          = 'rest-features'
  spec.version       = Rest::Features::VERSION
  spec.authors       = ['Alan Potter']
  spec.email         = ['alan.potter@conjur.net']

  spec.summary       = %q{Some support for writing features that test a REST API.}
  spec.description   = %q{Some support for writing features that test a REST API.}
  spec.homepage      = 'https://www.conjur.net'
  spec.license       = 'MIT'

  spec.files         = `git ls-files -z`.split("\x0").reject { |f| f.match(%r{^(test|spec)/}) }
  spec.require_paths = ["lib"]

  spec.add_dependency 'httparty', '~> 0.13'
  spec.add_development_dependency "bundler", "~> 1.10"
  spec.add_development_dependency "rake", "~> 10.0"
  spec.add_development_dependency "rspec"
end
