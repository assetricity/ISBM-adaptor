# -*- encoding: utf-8 -*-
$:.push File.expand_path('../lib', __FILE__)
require 'isbm-adaptor/version'

Gem::Specification.new do |s|
  s.name        = 'isbm-adaptor'
  s.version     = IsbmAdaptor::VERSION
  s.authors     = ['Assetricity']
  s.email       = ['info@assetricity.com']
  s.homepage    = 'http://www.assetricity.com'
  s.summary     = 'OpenO&M ISBM adaptor'
  s.description = 'OpenO&M ISBM adaptor based on Savon'

  s.files         = Dir.glob('lib/**/*') + Dir.glob('wsdls/*') + %w(LICENSE README.md)

  s.add_development_dependency 'rake', '~> 10.0.0'
  s.add_development_dependency 'rspec', '~> 2.13.0'
  s.add_development_dependency 'vcr', '~> 2.5.0'
  s.add_development_dependency 'webmock', '~> 1.11.0'

  s.add_runtime_dependency 'activesupport', '~> 3.0'
  s.add_runtime_dependency 'builder', '>= 3.0.0'
  s.add_runtime_dependency 'savon', '>= 2.0.0'
end
