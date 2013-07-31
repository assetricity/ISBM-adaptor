require 'bundler/gem_tasks'
require 'rspec/core/rake_task'
require 'isbm_adaptor'

RSpec::Core::RakeTask.new(:spec) do |t|
  t.rspec_opts = '--color'
end
task default: :spec

namespace :isbmadaptor do
  settings = YAML.load_file(File.expand_path(File.dirname(__FILE__)) + '/config/settings.yml')['development']
  endpoints = settings['endpoints']
  options = settings['options']
  channel_management_client = IsbmAdaptor::ChannelManagement.new(endpoints['channel_management'], options)
  provider_publication_client = IsbmAdaptor::ProviderPublication.new(endpoints['provider_publication'], options)

  desc 'Create channel with the given URI and type'
  task :create_channel, :uri, :channel_type do |t, args|
    uri = args.uri
    type = args.channel_type.to_sym
    channel_management_client.create_channel uri, type
  end

  desc 'Delete channel with the given URI'
  task :delete_channel, :uri do |t, args|
    uri = args.uri
    channel_management_client.delete_channel uri
  end

  desc 'Get channel with the given URI'
  task :get_channel, :uri do |t, args|
    uri = args.uri
    channel = channel_management_client.get_channel uri
    p channel
  end

  desc 'Get all channels'
  task :get_channels do
    channels = channel_management_client.get_channels
    puts "No. of Channels: #{channels.length}"
    puts '==================='
    channels.each { |channel| p channel }
  end

  desc 'Delete all channels'
  task :nuke_channels do
    channels = channel_management_client.get_channels
    channels.each { |c| channel_management_client.delete_channel c.uri }
  end

  desc 'Open a publication session on a given channel'
  task :open_publication_session, :uri do |t, args|
    uri = args.uri
    session_id = provider_publication_client.open_session uri
    p session_id
  end

  desc 'Post a message for a given session'
  task :post_publication, :session_id, :content, :topics, :expiry do |t, args|
    session_id = args.session_id
    content = args.content
    topics = args.topics
    expiry = args.expiry
    message_id = provider_publication_client.post_publication session_id, content, topics, expiry
    p message_id
  end

  desc 'Close the given publication session'
  task :close_publication, :session_id do |t, args|
    session_id = args.session_id
    provider_publication_client.close_publication session_id
  end
end
