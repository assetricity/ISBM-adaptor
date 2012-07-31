require 'rubygems'
require 'rspec'
require 'rspec/given'
require 'isbm'

$:.unshift File.expand_path('..', __FILE__)

ENV["RACK_ENV"] = 'test'
Isbm::Config.load!(File.join("config", "isbm.yml"))
