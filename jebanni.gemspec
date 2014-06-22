# coding: utf-8
lib = File.expand_path('../lib', __FILE__)
$LOAD_PATH.unshift(lib) unless $LOAD_PATH.include?(lib)
require 'jebanni/version'

Gem::Specification.new do |spec|
  spec.name          = "jebanni"
  spec.version       = Jebanni::VERSION
  spec.authors       = ["uu59"]
  spec.email         = ["k@uu59.org"]
  spec.summary       = %q{SSE Streaming server (not Rack)}
  spec.description   = %q{SSE Streaming server (not Rack)}
  spec.homepage      = ""
  spec.license       = "MIT"

  spec.files         = `git ls-files -z`.split("\x0")
  spec.executables   = spec.files.grep(%r{^bin/}) { |f| File.basename(f) }
  spec.test_files    = spec.files.grep(%r{^(test|spec|features)/})
  spec.require_paths = ["lib"]

  spec.add_dependency "reel"
  spec.add_dependency "mustermann"
  spec.add_dependency "rack" # for Rack::Utils#parse_nested_query
  spec.add_development_dependency "bundler", "~> 1.6"
  spec.add_development_dependency "rake"
  spec.add_development_dependency "pry"
end
