#TODO Update to account for Channel and Topic Objects or just fix info given by get_channel/topic_info
$:.unshift File.expand_path("../lib", __FILE__)

require 'bundler/gem_tasks'
require 'rspec/core/rake_task'
require 'isbm'

ENV["RACK_ENV"] = 'development'
Isbm::Config.load!(File.join("config", "isbm.yml"))

RSpec::Core::RakeTask.new do |t|
  t.rspec_opts = %w(--color)
end

namespace :isbm do
  # GetAllChannels
  desc "List all active ISBM Channel"
  task :list_channels do
    channels = Isbm::ChannelManagement.get_all_channels
    puts "Found #{channels.length} Active Channels"
    puts "==================="
    channels.each { |channel| puts channel }
  end

  # CreateChannel
  desc "Create Channel with give name and type"
  task :create_channel, :channel_name, :channel_type do |t, args|
    name = args.channel_name
    type = args.channel_type
    response = Isbm::ChannelManagement.create_channel :channel_name => name, :channel_type => type
    if Isbm.was_successful response
      puts "Channel created"
      puts "id: #{response[:channel_id]}"
    else
      puts "Error creating channel"
      puts "name: #{name}"
      puts "type: #{type}"
    end
  end

  # GetChannelInfo
  desc "Get Info of channel with given id"
  task :get_channel_info, :channel_id do |t, args|
    id = args.channel_id
    response = Isbm::ChannelManagement.get_channel_info :channel_id => id
    if Isbm.was_successful response
      puts "Successfully obtained channel info"
    else
      puts "Failed to retrieve channel info"
      puts (status_message response)
    end
    puts "channel_id: #{id}"
  end

  # DeleteChannel
  desc "Delete Channel with give id"
  task :delete_channel, :channel_id do |t, args|
    id = args.channel_id
    response = Isbm::ChannelManagement.delete_channel :channel_id => id
    if Isbm.was_successful response
      puts "Channel Deleted"
    else
      puts "Error deleting channel"
      puts (status_message response)
    end
      puts "channel_id: #{id}"
  end

  # CreateTopic
  desc "Create Topic with given name"
  task :create_topic, :channel_id, :topic do |t, args|
    channel_id = args.channel_id
    topic = args.topic
    response = Isbm::ChannelManagement.create_topic :channel_id => channel_id, :topic => topic
    if Isbm.was_successful response
      puts "Topic Created"
    else
      puts "Error creating topic"
      puts (status_message response)
    end
    puts "channel_id: #{channel_id}"
    puts "topic: #{topic}"
  end

  # DeleteTopic
  desc "Open Publication Session on a channel"
  task :delete_topic, :channel_id, :topic do |t, args|
    channel_id = args.channel_id
    topic = args.topic
    response = Isbm::ChannelManagement.delete_topic :channel_id => channel_id, :topic => topic
    if Isbm.was_successful response
      puts "Topic Deleted"
    else
      puts "Error Deleting Topic"
      puts (status_message response)
    end
    puts "channel_id: #{channel_id}"
    puts "topic: #{topic}"
  end

  # OpenPublication
  desc "Open a Publication Session on a given Channel"
  task :open_publication, :channel_id do |t, args|
    channel_id = args.channel_id
    response = Isbm::ProviderPublication.open_publication :channel_id => channel_id
    if Isbm.was_successful response
      puts "Publication Session Created"
    else
      puts "Error Creating Publication Session"
      puts (status_message response)
    end
    puts "channel_id: #{channel_id}"
    puts "channel_session_id: #{response[:channel_session_id]}"
  end

  # ClosePublication
  desc "Close Publication Session with given ID"
  task :close_publication, :channel_session_id do |t, args|
    channel_session_id= args.channel_session_id
    response = Isbm::ProviderPublication.close_publication :channel_session_id => channel_session_id
    if Isbm.was_successful response
      puts "Publication Session Closed"
    else
      puts "Error Closing Publication Session"
      puts (status_message response)
    end
    puts "channel_session_id #{channel_session_id}"
  end

  # PostPublication
  desc "Post a Message to the Publication Session"
  task :post_publication, :channel_session_id, :topic, :publication_message do |t, args|
    channel_session_id = args.channel_session_id
    topic = args.topic
    publication_message = args.publication_message
    response = Isbm::ProviderPublication.post_publication :channel_session_id => channel_session_id, :topic => topic, :publication_message => publication_message
    if Isbm.was_successful response
      puts "Successfully Posted Publication"
    else
      puts "Error Posting Publication"
      puts (status_message response)
    end
    puts "channel_session_id #{channel_session_id}"
    puts "topic #{topic}"
    puts "publication_message #{publication_message}"
  end
  task :nuke do
    Isbm::ChannelManagement.delete_all_channels
  end

  def status_message(response)
    (message = Isbm.get_status_message response)? message : "No status message"
  end
end
