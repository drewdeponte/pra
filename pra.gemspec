# coding: utf-8
lib = File.expand_path('../lib', __FILE__)
$LOAD_PATH.unshift(lib) unless $LOAD_PATH.include?(lib)
require 'pra/version'

Gem::Specification.new do |spec|
  spec.name          = "pra"
  spec.version       = Pra::VERSION
  spec.authors       = ["Andrew De Ponte"]
  spec.email         = ["cyphactor@gmail.com"]
  spec.description   = %q{Command Line utility to make you aware of open pull-requests across systems at all times.}
  spec.summary       = %q{CLI tool that shows open pull-requests across systems.}
  spec.homepage      = "http://github.com/reachlocal/pra"
  spec.license       = "MIT"

  spec.files         = `git ls-files`.split($/)
  spec.executables   = spec.files.grep(%r{^bin/}) { |f| File.basename(f) }
  spec.test_files    = spec.files.grep(%r{^(test|spec|features)/})
  spec.require_paths = ["lib"]

  spec.add_development_dependency "bundler", "~> 1.5"
  spec.add_development_dependency "rake", "~> 10.1"
  spec.add_development_dependency "rspec", "~> 2.14"

  spec.add_dependency "rest-client", "~> 1.6"
  spec.add_dependency "launchy", "~> 2.4"
  spec.add_dependency "curses", "~> 1.0"
end
