require 'rubygems'
require 'rspec'
require 'rspec/given'
require 'isbm'

$:.unshift File.expand_path('..', __FILE__)

RSpec.configure do |config|
  config.before(:all) do
    @channels = Isbm::ChannelManagement.get_all_channels
  end

  config.after(:all) do
    channels_after_specs = Isbm::ChannelManagement.get_all_channels
    puts "ISBM was left with #{ channels_after_specs.length - @channels.length} open test channels" if @channels.length != channels_after_specs.length
  end
end
