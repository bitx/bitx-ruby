# coding: utf-8
lib = File.expand_path('../lib', __FILE__)
$LOAD_PATH.unshift(lib) unless $LOAD_PATH.include?(lib)

require_relative 'lib/version'

Gem::Specification.new do |spec|
  spec.name          = "bitx"
  spec.version       = BitX::VERSION::STRING.dup
  spec.authors       = ["Timothy Stranex","Francois Paul"]
  spec.email         = ["timothy@bitx.co","franc@bitx.co"]
  spec.description   = 'BitX API wrapper'
  spec.summary       = 'Ruby wrapper for the BitX API'
  spec.homepage      = "https://bitx.co/api"
  spec.license       = "MIT"

  spec.files         = `git ls-files`.split($/)
  spec.executables   = spec.files.grep(%r{^bin/}) { |f| File.basename(f) }
  spec.test_files    = spec.files.grep(%r{^(test|spec|features)/})
  spec.require_paths = ["lib"]

  spec.add_development_dependency "bundler", "~> 1.3"
  spec.add_development_dependency "rake"
  spec.add_development_dependency "minitest"
  spec.add_runtime_dependency 'faraday'
end
