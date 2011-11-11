require 'rubygems'
require 'rspec'
require 'rspec/given'
require 'isbm'
require 'log_buddy'

$:.unshift File.expand_path('..', __FILE__)

ENV["RACK_ENV"] = 'test'
Isbm::Config.load!(File.join("spec", "fixtures", "isbm.yml"))

RSpec.configure do |config|
  # config.before(:all) do
  # end

  # config.after(:all) do
  #   channels_after_specs = Isbm::ChannelManagement.get_all_channels
  #   puts "ISBM was left with #{ channels_after_specs.length - @channels.length} open test channels" if @channels.length != channels_after_specs.length
  # end
end
