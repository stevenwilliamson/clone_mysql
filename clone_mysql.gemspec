# coding: utf-8
lib = File.expand_path('../lib', __FILE__)
$LOAD_PATH.unshift(lib) unless $LOAD_PATH.include?(lib)
require 'clone_mysql/version'

Gem::Specification.new do |spec|
  spec.name          = "clone_mysql"
  spec.version       = CloneMysql::VERSION
  spec.authors       = ["Steven Williamson"]
  spec.email         = ["steve@freeagent.com"]
  spec.summary       = %q{Create and manage a clone of MySQL.}
  spec.description   = %q{ZFS Clone a mysql dataset and run a new version of mysql using the clone.}
  spec.homepage      = ""
  spec.license       = "MIT"

  spec.files         = `git ls-files -z`.split("\x0")
  spec.executables   = spec.files.grep(%r{^bin/}) { |f| File.basename(f) }
  spec.test_files    = spec.files.grep(%r{^(test|spec|features)/})
  spec.require_paths = ["lib"]

  spec.add_development_dependency "bundler", "~> 1.7"
  spec.add_development_dependency "rake", "~> 10.0"
  spec.add_runtime_dependency "zfs", "~> 0.1.1"
  spec.add_runtime_dependency "gli", "~> 2.12.2"

end
