$:.unshift File.expand_path("../lib", __FILE__)

require "bundler/gem_tasks"
require 'rspec/core/rake_task'
require 'isbm'

RSpec::Core::RakeTask.new do |t|
  t.rspec_opts = %w(--color)
end

task :delete_channels do
  Isbm::ChannelManagement.delete_all
end
