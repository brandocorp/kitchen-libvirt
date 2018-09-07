# -*- encoding: utf-8 -*-
lib = File.expand_path('../lib', __FILE__)
$LOAD_PATH.unshift(lib) unless $LOAD_PATH.include?(lib)
require 'kitchen/driver/libvirt_version.rb'

Gem::Specification.new do |gem|
  gem.name          = 'kitchen-libvirt'
  gem.version       = Kitchen::Driver::LIBVIRT_VERSION
  gem.license       = 'Apache 2.0'
  gem.authors       = ['Brandon Raabe']
  gem.email         = ['brandocorp@gmail.com']
  gem.description   = 'A Test Kitchen Driver for Libvirt'
  gem.summary       = gem.description
  gem.homepage      = 'https://github.com/brandocorp/kitchen-libvirt'

  gem.files         = `git ls-files`.split($INPUT_RECORD_SEPARATOR)
  gem.executables   = []
  gem.test_files    = gem.files.grep(%r{^(test|spec|features)/})
  gem.require_paths = ['lib']

  # gem.required_ruby_version = '>= 2.2.2'

  gem.add_dependency 'test-kitchen', '~> 1.4', '>= 1.4.1'
  gem.add_dependency 'fog-libvirt', '~> 0.5.0' 

  gem.add_development_dependency 'rspec',     '~> 3.2'
  gem.add_development_dependency 'simplecov', '~> 0.7'
  gem.add_development_dependency 'yard',      '~> 0.9', '>= 0.9.11'
end
