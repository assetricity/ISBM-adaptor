$:.unshift File.expand_path("../lib", __FILE__)

require 'bundler/gem_tasks'
require 'rspec/core/rake_task'
require 'isbm'

ENV["RACK_ENV"] ||= 'development'
Isbm::Config.load(File.join("config", "isbm.yml"), ENV["RACK_ENV"])

RSpec::Core::RakeTask.new do |t|
  t.rspec_opts = %w(--color)
end

namespace :isbm do
  desc "Create channel with the given URI and type"
  task :create_channel, :uri, :channel_type do |t, args|
    uri = args.uri
    type = args.channel_type.to_sym
    Isbm::ChannelManagement.create_channel uri, type
  end

  desc "Delete channel with the given URI"
  task :delete_channel, :uri do |t, args|
    uri = args.uri
    Isbm::ChannelManagement.delete_channel uri
  end

  desc "Get channel with the given URI"
  task :get_channel, :uri do |t, args|
    uri = args.uri
    channel = Isbm::ChannelManagement.get_channel uri
    p channel
  end

  desc "Get all channels"
  task :get_channels do
    channels = Isbm::ChannelManagement.get_channels
    puts "No. of Channels: #{channels.length}"
    puts "==================="
    channels.each { |channel| p channel }
  end

  desc "Delete all channels"
  task :nuke_channels do
    channels = Isbm::ChannelManagement.get_channels
    channels.each { |c| Isbm::ChannelManagement.delete_channel c.uri }
  end

  desc "Open a publication session on a given channel"
  task :open_publication_session, :uri do |t, args|
    uri = args.uri
    session_id = Isbm::ProviderPublication.open_session uri
    puts session_id
  end

  desc "Post a message for a given session"
  task :post_publication, :session_id, :content, :topics, :expiry do |t, args|
    session_id = args.session_id
    content = args.content
    topics = args.topics
    expiry = args.expiry
    message_id = Isbm::ProviderPublication.post_publication session_id, content, topics, expiry
    puts message_id
  end

  desc "Close the given publication session"
  task :close_publication, :session_id do |t, args|
    session_id = args.session_id
    Isbm::ProviderPublication.close_publication session_id
  end
end
