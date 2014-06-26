require 'rubygems'
require 'active_support/inflector'
require 'rspec'
require 'webmock/rspec'
require 'vcr'
require 'isbm_adaptor'

if ENV['COVERAGE'] == 'on'
  require 'coveralls'
  Coveralls.wear!
end

settings = YAML.load_file(File.expand_path(File.dirname(__FILE__)) + '/../config/settings.yml')['test']
ENDPOINTS = settings['endpoints']
OPTIONS = settings['options']

VCR.configure do |c|
  c.cassette_library_dir = 'spec/cassettes'
  c.hook_into :webmock
  c.configure_rspec_metadata!
end

RSpec.configure do |config|
  config.treat_symbols_as_metadata_keys_with_true_values = true
end
