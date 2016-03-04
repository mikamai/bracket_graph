# coding: utf-8
lib = File.expand_path('../lib', __FILE__)
$LOAD_PATH.unshift(lib) unless $LOAD_PATH.include?(lib)
require 'bracket_graph/version'

Gem::Specification.new do |spec|
  spec.name          = "bracket_graph"
  spec.version       = BracketGraph::VERSION
  spec.authors       = ["Nicola Racco"]
  spec.email         = ["nicola@nicolaracco.com"]
  spec.summary       = %q{Tree management library}
  spec.description   = %q{Tree management library}
  spec.homepage      = ""
  spec.license       = "MIT"

  spec.files         = `git ls-files -z`.split("\x0")
  spec.executables   = spec.files.grep(%r{^bin/}) { |f| File.basename(f) }
  spec.test_files    = spec.files.grep(%r{^(test|spec|features)/})
  spec.require_paths = ["lib"]

  spec.add_dependency "activesupport"

  spec.add_development_dependency "bundler", "~> 1.5"
  spec.add_development_dependency "rake"
  spec.add_development_dependency "guard-rspec"
end
