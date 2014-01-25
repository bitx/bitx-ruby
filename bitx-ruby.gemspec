# coding: utf-8
lib = File.expand_path('../lib', __FILE__)
$LOAD_PATH.unshift(lib) unless $LOAD_PATH.include?(lib)

Gem::Specification.new do |spec|
  spec.name          = "bitx-ruby"
  spec.version       = '0.0.1'
  spec.authors       = ["Timothy Stranex"]
  spec.email         = ["timothy@switchless.com"]
  spec.description   = 'BitX API wrapper'
  spec.summary       = 'Ruby wrapper for the BitX API'
  spec.homepage      = "https://bitx.co.za/api"
  spec.license       = "MIT"

  spec.files         = `git ls-files`.split($/)
  spec.executables   = spec.files.grep(%r{^bin/}) { |f| File.basename(f) }
  spec.test_files    = spec.files.grep(%r{^(test|spec|features)/})
  spec.require_paths = ["lib"]

  spec.add_development_dependency "bundler", "~> 1.3"
  spec.add_development_dependency "rake"
end
