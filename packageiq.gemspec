# coding: utf-8
lib = File.expand_path('../lib', __FILE__)
$LOAD_PATH.unshift(lib) unless $LOAD_PATH.include?(lib)
require 'packageiq/version'

Gem::Specification.new do |spec|
  spec.name          = 'packageiq'
  spec.version       = Packageiq::VERSION
  spec.authors       = ['Eric Olsen']
  spec.email         = ['eric@ericolsen.net']

  spec.summary       = 'Package Intelligence Gathering System'
  spec.description   = 'Package Intelligence Gathering System'
  spec.homepage      = 'http://www.packageiq.io'

  # Prevent pushing this gem to RubyGems.org by setting 'allowed_push_host', or
  # delete this section to allow pushing this gem to any host.
  if spec.respond_to?(:metadata)
    spec.metadata['allowed_push_host'] = 'https://rubygems.org'
  else
    fail 'RubyGems 2.0 or newer is required to protect against public gem pushes.'
  end

  spec.files         = `git ls-files -z`.split("\x0").reject { |f| f.match(%r{^(test|spec|features)/}) }
  spec.bindir        = 'exe'
  spec.executables   = spec.files.grep(%r{^exe/}) { |f| File.basename(f) }
  spec.require_paths = ['lib']

  spec.add_dependency 'bunny', '~> 2.2.2'
  spec.add_dependency 'json', '~> 1.8.3'
  spec.add_dependency 'sneakers', '~> 2.3.5'
  spec.add_dependency 'elasticsearch', '~> 1.0.15'

  spec.add_development_dependency 'bundler', '~> 1.10'
  spec.add_development_dependency 'rake', '~> 10.0'
  spec.add_development_dependency 'pleaserun', '~> 0.0.16'
  spec.add_development_dependency 'fpm', '~> 1.4.0'
  spec.add_development_dependency 'fpm-cookery', '~> 0.31.0'
end
