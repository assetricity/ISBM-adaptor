$:.push File.expand_path('../lib', __FILE__)
require 'isbm_adaptor/version'

Gem::Specification.new do |s|
  s.name     = 'isbm_adaptor'
  s.version  = IsbmAdaptor::VERSION
  s.authors  = ['Assetricity']
  s.email    = ['info@assetricity.com']
  s.homepage = 'https://github.com/assetricity/isbm_adaptor'
  s.summary  = 'ISBM Adaptor provides a Ruby API for the OpenO&M ISBM specification'
  s.license  = 'MIT'

  s.files    = Dir.glob('lib/**/*') + Dir.glob('wsdls/*') + %w(LICENSE README.md)

  s.add_development_dependency 'rake', '~> 10.3.0'
  s.add_development_dependency 'rspec', '~> 2.14.0'
  s.add_development_dependency 'vcr', '~> 2.9.0'
  s.add_development_dependency 'webmock', '~> 1.18.0'

  s.add_runtime_dependency 'activesupport', '>= 1.0.0'
  s.add_runtime_dependency 'akami', '>= 1.0.0'
  s.add_runtime_dependency 'builder', '>= 2.1.2'
  s.add_runtime_dependency 'nokogiri', '>= 1.4.0'
  s.add_runtime_dependency 'savon', '>= 2.0.0'
end
