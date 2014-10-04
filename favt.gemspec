# coding: utf-8
lib = File.expand_path('../lib', __FILE__)
$LOAD_PATH.unshift(lib) unless $LOAD_PATH.include?(lib)
require 'favt/version'

Gem::Specification.new do |spec|
  spec.name          = "favt"
  spec.version       = Favt::VERSION
  spec.authors       = ["esehara shigeo"]
  spec.email         = ["esehara@gmail.com"]
  spec.summary       = %q{Twitter Cliant for Favorite}
  spec.description   = %q{Twitter Client for post favorited by users}
  spec.homepage      = ""
  spec.license       = "MIT"

  spec.files         = `git ls-files -z`.split("\x0")
  spec.executables   = ["favt"]
  spec.test_files    = spec.files.grep(%r{^(test|spec|features)/})
  spec.require_paths = ["lib"]
  
  spec.add_dependency "twitter"
  spec.add_dependency "colorize"
  spec.add_development_dependency "bundler", "~> 1.7"
  spec.add_development_dependency "rake", "~> 10.0"
end
