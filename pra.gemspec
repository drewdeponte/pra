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
  spec.homepage      = "http://github.com/codebreakdown/pra"
  spec.license       = "MIT"

  spec.files         = `git ls-files -z`.split("\x0").reject { |f| f.match(%r{^(test|spec|features)/}) }
  spec.bindir        = "exe"
  spec.executables   = spec.files.grep(%r{^exe/}) { |f| File.basename(f) }
  spec.test_files    = spec.files.grep(%r{^(test|spec|features)/})
  spec.require_paths = ["lib"]

  spec.add_development_dependency "bundler", "~> 1.10"
  spec.add_development_dependency "rake", "~> 10.1"
  spec.add_development_dependency "rspec", "~> 3.5"
  spec.add_development_dependency "timecop", "~> 0.8"

  spec.add_dependency "faraday", "~> 0.9"
  spec.add_dependency "launchy", "~> 2.4"
  spec.add_dependency "curses", "~> 1.0"
  spec.add_dependency "time-lord", "~> 1.0"
end
