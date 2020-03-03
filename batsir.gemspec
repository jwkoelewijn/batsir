# -*- encoding: utf-8 -*-
lib = File.expand_path('../lib', __FILE__)
$LOAD_PATH.unshift(lib) unless $LOAD_PATH.include?(lib)
require 'batsir/version'

Gem::Specification.new do |s|
  s.name          = 'batsir'
  s.version       = Batsir::VERSION
  s.date          = '2014-10-06'
  s.authors       = ['J.W. Koelewijn', 'Bram de Vries']
  s.email         = 'jwkoelewijn@gmail.com'
  s.summary       = 'Batsir is a platform for stage based operation queue execution'
  s.homepage      = 'http://github.com/jwkoelewijn/batsir'
  s.license       = 'MIT'

  s.files         = Dir['README.md', 'CHANGES.md', 'LICENSE.txt', 'lib/**/*']
  s.executables   = s.files.grep(%r{^bin/}) { |f| File.basename(f) }
  s.test_files    = s.files.grep(%r{^(test|spec|features)/})
  s.require_paths = ['lib']

  s.extra_rdoc_files = ['CHANGES.md', 'LICENSE.txt', 'README.md']

  s.add_dependency 'blockenspiel',  '>= 0.4.3'
  s.add_dependency 'celluloid',     '< 0.16.0'
  s.add_dependency 'sidekiq'
  s.add_dependency 'bunny',         '>= 1.0.0'
  s.add_dependency 'json'
  s.add_dependency 'log4r'

  s.add_development_dependency 'bundler', '~> 1.7'
  s.add_development_dependency 'rake',    '~> 12.3.3'
  s.add_development_dependency 'rspec'
end
