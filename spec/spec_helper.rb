require 'rubygems'
require 'rspec'
require 'rspec/given'
require 'isbm'
require 'log_buddy'

$:.unshift File.expand_path('..', __FILE__)

ENV["RACK_ENV"] = 'test'
Isbm::Config.load!(File.join("config", "isbm.yml"))

RSpec.configure do |config|
end
