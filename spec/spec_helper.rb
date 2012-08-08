require 'rubygems'
require 'rspec'
require 'vcr'
require 'fakeweb'
require 'awesome_print'
require 'isbm'

$:.unshift File.expand_path('..', __FILE__)

ENV["RACK_ENV"] = 'test'
Isbm::Config.load(File.join("config", "isbm.yml"))

class String
  def underscore
    word = self.dup
    word.gsub!(/::/, '/')
    word.gsub!(/([A-Z\d]+)([A-Z][a-z])/,'\1_\2')
    word.gsub!(/([a-z\d])([A-Z])/,'\1_\2')
    word.tr!("-", "_")
    word.downcase!
    word
  end
end

class Hash
  # https://github.com/rails/rails/blob/1eecd9483b0439ab4913beea36f0d0e2aa0518c7/activesupport/lib/active_support/core_ext/hash/except.rb#L14
  def except(*keys)
    dup.except!(*keys)
  end

  def except!(*keys)
    keys.each { |key| delete(key) }
    self
  end

  # https://github.com/rails/rails/blob/308595739c32609ac5b167ecdc6cb6cb4ec6c81f/activesupport/lib/active_support/core_ext/hash/slice.rb#L15
  def slice(*keys)
    keys = keys.map! { |key| convert_key(key) } if respond_to?(:convert_key)
    hash = self.class.new
    keys.each { |k| hash[k] = self[k] if has_key?(k) }
    hash
  end
end

# This will configure VCR to record http traffic using fakeweb on
# tests that have the :vcr symbol next to the description
VCR.configure do |c|
  c.default_cassette_options = { :record => :new_episodes }
  c.cassette_library_dir = 'spec/cassettes'
  c.hook_into :fakeweb
  c.ignore_localhost = true
end

RSpec.configure do |config|
  config.treat_symbols_as_metadata_keys_with_true_values = true

  # A little trick we use to easily make a test use vcr by
  # just tagging it with :vcr
  config.around(:each, :vcr) do |example|
    name = example.metadata[:full_description].split(/\s+/, 2).join('/').underscore.gsub(/[^\w\/]+/, '_')
    options = example.metadata.slice(:record, :match_requests_on).except(:example_group)
    VCR.use_cassette(name, options) { example.call }
  end
end
