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

  s.add_development_dependency 'rake', '~> 10.0.0'
  s.add_development_dependency 'rspec', '~> 2.13.0'
  s.add_development_dependency 'vcr', '~> 2.5.0'
  s.add_development_dependency 'webmock', '~> 1.11.0'

  s.add_runtime_dependency 'activesupport', '>= 3.0.0'
  s.add_runtime_dependency 'builder', '>= 3.0.0'
  s.add_runtime_dependency 'savon', '>= 2.0.0'
end
