# coding: utf-8
lib = File.expand_path('../lib', __FILE__)
$LOAD_PATH.unshift(lib) unless $LOAD_PATH.include?(lib)
require 'wfl_file_base/version'

Gem::Specification.new do |spec|
  spec.name          = "wfl_file_base"
  spec.version       = WflFileBase::VERSION
  spec.authors       = ["wpzero"]
  spec.email         = ["wpcreep@gmail.com"]
  spec.summary       = %q{map file to a range of ORMs, store them on different backends}
  spec.description   = %q{map file to a range of ORMs, store them on different backends. it can bind a record to a folder}
  spec.homepage      = "https://github.com/wpzero/wfl_file_base"
  spec.license       = "MIT"

  spec.files         = `git ls-files -z`.split("\x0")
  spec.executables   = spec.files.grep(%r{^bin/}) { |f| File.basename(f) }
  spec.test_files    = spec.files.grep(%r{^(test|spec|features)/})
  spec.require_paths = ["lib"]

  spec.add_dependency "activerecord" 
  spec.add_development_dependency "bundler", "~> 1.6"
  spec.add_development_dependency "rake"
end
