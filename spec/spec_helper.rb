require 'rubygems'
require 'active_support/core_ext/hash'
require 'active_support/inflector'
require 'rspec'
require 'webmock/rspec'
require 'vcr'
require 'isbm_adaptor'
require 'coveralls'

if ENV['COVERAGE'] == 'on'
  Coveralls.wear!
end

settings = YAML.load_file(File.expand_path(File.dirname(__FILE__)) + '/../config/settings.yml')['test']
ENDPOINTS = settings['endpoints']
OPTIONS = settings['options']

VCR.configure do |c|
  c.default_cassette_options = { record: :new_episodes }
  c.cassette_library_dir = 'spec/cassettes'
  c.hook_into :webmock
  c.ignore_localhost = true
end

RSpec.configure do |config|
  config.treat_symbols_as_metadata_keys_with_true_values = true

  # Make a test use VCR by tagging it with :vcr
  config.around(:each, :vcr) do |example|
    name = example.metadata[:full_description].split(/\s+/, 2).join('/').underscore.gsub(/[^\w\/]+/, '_')
    options = example.metadata.slice(:record, :match_requests_on).except(:example_group)
    VCR.use_cassette(name, options) { example.call }
  end
end
