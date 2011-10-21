module Isbm
  class ChannelManagement
    include Savon::Model
    include Isbm

    document  "wsdls/ISBMChannelManagementService.wsdl"
    endpoint  "http://172.16.72.31:9080/IsbmModuleWeb/sca/ISBMChannelManagementServiceSoapExport"
    @@channel_types = [nil, "Publication"]

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
      validate_presense_of args, :channel_name, :channel_type
      response = client.request :wsdl, "CreateChannel" do
        soap.body = {
          :channel_name => args.first[:channel_name],
          :channel_type => args.first[:channel_type]
        }
      end
      response.to_hash[:create_channel_response]
    end

    # Creates a topic on a channel on the ISBM
    # Arguments (Required)
    #   :channel_id
    #   :topic
    #
    # Arguments (optional)
    #   :description
    #   :xpath_definition
    def self.create_topic(*args)
      validate_presense_of args, :channel_id, :topic
      response = client.request :wsdl, "CreateTopic" do
        soap.body = {
          :channel_i_d => args.first[:channel_id],
          :topic => args.first[:topic],
          :description => args.first[:description],
          :xpath_definition => args.first[:xpath_definition]
        }
      end
      response.to_hash[:create_topic_response]
    end

    # Returns an array of channel IDs ["ID1", "ID2", "ID3"]
    #
    # WSDL: GetAllChannels
    def self.get_all_channels
      response = client.request :wsdl, "GetAllChannels"
      channel_ids = response.to_hash[:get_all_channels_response][:channel_id]
      channel_ids.is_a?(Array) ? channel_ids.compact : [channel_ids].compact
    end

    # Returns an array of Topic IDs 
    # <tt>
    # Isbm::Topic => ["Topic1", "Topic2"]
    # </tt>
    #
    # WSDL: GetAllTopics
    def self.get_all_topics(ch_id)
      response = client.request :wsdl, "GetAllTopics" do
        soap.body = {
          :channel_i_d => ch_id
        }
      end
      response.to_hash
      topics = response.to_hash[:get_all_topics_response][:topic]
      topics.is_a?(Array) ? topics : [topics]
    end

    # Returns an Isbm::Channel object with cached channel information
    # this object can potnetially become unsynced with the ISBM
    # and should be reloaded periodically to avoid this
    #
    # <tt>
    # Isbm::ChannelManagement.get_channel "someid" => new Isbm::Channel
    # </tt>
    def self.get_channel(channel_id)
      args = Isbm::ChannelManagement.get_channel_info( :channel_id => channel_id ).merge( { :channel_id => channel_id } )
      Isbm::Channel.new args
    end

    # Returns a hash of channel info for the given channel
    # Arguments (Required)
    #   :channel_id
    #
    # WSDL: GetChannelInfo
    def self.get_channel_info(*args)
      validate_presense_of args, :channel_id
      channel_id = args.first[:channel_id]
      response = client.request :wsdl, "GetChannelInfo" do
        soap.body = {
          :channel_i_d => channel_id
        }
      end
      response.to_hash[:get_channel_info_response]
    end

    # Gives detailed topic information
    # Arguments (required)
    #   :channel_id
    #   :topic_name
    #
    # WSDL: GetTopicInfo
    def self.get_topic_info(*args)
      validate_presense_of args, :channel_name, :channel_type
      response = client.request :wsdl, "GetTopicInfo" do
        soap.body = {
          :channel_i_d => args.first[:channel_id],
          :topic => args.first[:topic_name]
        }
      end
      response.to_hash[:get_topic_info_response]
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
    #   :topic
    #
    # WSDL: DeleteTopic
    def self.delete_topic(*args)
      validate_presense_of args, :channel_id, :topic
      response = client.request :wsdl, "DeleteTopic" do
        soap.body = {
          :channel_i_d => args.first[:channel_id],
          :topic => args.first[:topic]
        }
      end
      response.to_hash[:delete_topic_response]
    end

    # Used to nuke the ISBM of all channels. Probably shouldn't exists
    def self.delete_all_channels
      Isbm::ChannelManagement.get_all_channels.each do |id|
        client.request :wsdl, "DeleteChannel" do
          soap.body = {
            :channel_i_d => id
          }
        end
      end
    end

    # Get list of topics for channel with given ID
    def self.get_topics(id)
      channel= Isbm::ChannelManagement.get_channel id
      channel.topic_names
    end
  end
end
