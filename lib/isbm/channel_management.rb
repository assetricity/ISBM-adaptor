module Isbm
  class ChannelManagement
    include Savon::Model
    include Isbm

    document  Isbm.wsdl_dir + "ISBMChannelManagementService.wsdl"
    endpoint  Isbm::Config.channel_management_endpoint

    def self.channel_types; [nil, "Publication", "Request", "Response"] end

    # Creates a channel on the ISBM
    # Arguments (Required)
    #   :channel_name
    #   :channel_type
    #
    # Creates a channel on the ISBM
    # Returns a hash containing the id and details of the created channel
    #
    # WSDL: CreateChannel
    def self.create_channel(*args)
      ch_type = args.first[:channel_type]
      ch_name = args.first[:channel_name]
      ch_description = args.first[:channel_description] || ''
      validate_presense_of args, :channel_name, :channel_type
      not_valid_chtype ch_type unless self.channel_types.include? ch_type
      response = client.request :wsdl, "CreateChannel" do
        soap.body = {
          :channel_name => ch_name,
          :channel_type => ch_type,
          :channel_description => ch_description
        }
      end
      response.to_hash[:create_channel_response]
    end

    # Creates a topic on a channel on the ISBM
    # Arguments (Required)
    #   :channel_id
    #   :topic_name
    #
    # Arguments (optional)
    #   :topic_description
    #   :xpath_expression
    def self.create_topic(*args)
      validate_presense_of args, :channel_id, :topic_name
      response = client.request :wsdl, "CreateTopic" do
        soap.body = {
          :channel_i_d => args.first[:channel_id],
          :topic_name => args.first[:topic_name],
          :topic_description => args.first[:topic_description] || '',
          :x_path_expression => args.first[:xpath_expression] || ''
        }
      end
      response.to_hash[:create_topic_response]
    end

    # WSDL: GetChannels
    def self.get_all_channels
      response = client.request :wsdl, "GetChannels"
      channels = response.to_hash[:get_channels_response][:channel]
      channels.is_a?(Array) ? channels.compact : [channels].compact
    end

    # Returns an array of Topic IDs 
    # <tt>
    # Isbm::Topic => ["Topic1", "Topic2"]
    # </tt>
    #
    # WSDL: GetTopics
    def self.get_topics(*args)
      validate_presense_of args, :channel_id
      response = client.request :wsdl, "GetTopics" do
        soap.body = {
          :channel_i_d => args.first[:channel_id]
        }
      end
      response.to_hash
      topics = response.to_hash[:get_topics_response][:topic]
      return [] if topics.nil?
      topics.is_a?(Array) ? topics : [topics].compact
    end

    # Returns a hash of channel info for the given channel
    # Arguments (Required)
    #   :channel_name
    #   :channel_type
    #
    # WSDL: GetChannel
    def self.get_channel_info(*args)
      validate_presense_of args, :channel_name, :channel_type
      channel_name = args.first[:channel_name]
      channel_type = args.first[:channel_type]
      response = client.request :wsdl, "GetChannel" do
        soap.body = {
          :channel_name => channel_name,
          :channel_type => channel_type
        }
      end
      response.to_hash[:get_channel_response][:channel]
    end

    # Gives detailed topic information
    # Arguments (required)
    #   :channel_id
    #   :topic_name
    #
    # WSDL: GetTopic
    def self.get_topic_info(*args)
      validate_presense_of args, :channel_id, :topic_name
      response = client.request :wsdl, "GetTopic" do
        soap.body = {
          :channel_i_d => args.first[:channel_id],
          :topic_name => args.first[:topic_name]
        }
      end
      response.to_hash[:get_topic_response][:topic]
    end

    # Give detailed session information
    # Arguments (required)
    #   :session_id
    #
    # WSDL: GetSession
    def self.get_session_info(*args)
      validate_presense_of args, :session_id
      response = client.request :wsdl, "GetSession" do
        soap.body = {
          :session_i_d => args.first[:session_id]
        }
      end
      response.to_hash[:get_session_response][:session]
    end

    def self.get_sessions(*args)
      validate_presense_of args, :channel_id
      response = client.request :wsdl, "GetSessions" do
        soap.body = {
          :channel_i_d => args.first[:channel_id]
        }
      end
      sessions = response.to_hash[:get_sessions_response][:session]
      sessions.is_a?(Array) ? sessions : [sessions].compact
    end

    # Deletes a channel of the given id
    # Arguments (Required)
    #   :channel_id
    #
    # WSDL: DeleteChannel
    def self.delete_channel(*args)
      begin
        validate_presense_of args, :channel_id
        response = client.request :wsdl, "DeleteChannel" do
          soap.body = {
            :channel_i_d => args.first[:channel_id]
          }
        end
        response.to_hash[:delete_channel_response]
      rescue Isbm::ArgumentError => ex
        Isbm.logger.debug ex.message
      end
    end

    # Request to delete a channel
    # Arguments (Required)
    #   :channel_id
    #   :topic_name
    #
    # WSDL: DeleteTopic
    def self.delete_topic(*args)
      validate_presense_of args, :channel_id, :topic
      response = client.request :wsdl, "DeleteTopic" do
        soap.body = {
          :channel_i_d => args.first[:channel_id],
          :topic_name => args.first[:topic_name]
        }
      end
      response.to_hash[:delete_topic_response]
    end

    # Used to nuke the ISBM of all channels. Probably shouldn't exists
    def self.delete_all_channels
      Isbm::ChannelManagement.get_all_channels.each do |channel|
        client.request :wsdl, "DeleteChannel" do
          soap.body = {
            :channel_i_d => channel[:channel_id]
          }
        end
      end
    end
  end
end
