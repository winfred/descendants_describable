# coding: utf-8
lib = File.expand_path('../lib', __FILE__)
$LOAD_PATH.unshift(lib) unless $LOAD_PATH.include?(lib)
require 'descendants_describable/version'

Gem::Specification.new do |spec|
  spec.name          = "descendants_describable"
  spec.version       = DescendantsDescribable::VERSION
  spec.authors       = ["winfred"]
  spec.email         = ["winfred@hired.com"]
  spec.description   = %q{Turn a module of behavioral concerns into a DSL for describing a large set of subtypes}
  spec.summary       = %q{Turn a module of behavioral concerns into a DSL for describing a large set of subtypes}
  spec.homepage      = "http://github.com/hired/descendants_describable"
  spec.license       = "MIT"

  spec.files         = `git ls-files`.split($/)
  spec.executables   = spec.files.grep(%r{^bin/}) { |f| File.basename(f) }
  spec.test_files    = spec.files.grep(%r{^(test|spec|features)/})
  spec.require_paths = ["lib"]

  spec.add_dependency 'activerecord', '>= 3.0'
  spec.add_dependency 'activesupport', '>= 3.0'
  spec.add_development_dependency "bundler", "~> 1.3"
  spec.add_development_dependency "rake"
  spec.add_development_dependency "rspec"
  spec.add_development_dependency "pry"
  spec.add_development_dependency "sqlite3"
end
