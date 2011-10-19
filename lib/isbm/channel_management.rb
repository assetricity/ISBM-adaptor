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
          "channelName" => args.first[:channel_name],
          "channelType" => args.first[:channel_type]
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
          "channelID" => args.first[:channel_id],
          "topic" => args.first[:topic],
          "description" => args.first[:description],
          "xpathDefinition" => args.first[:xpath_definition]
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
          "channelID" => ch_id
        }
      end
      response.to_hash
      topics = response.to_hash[:get_all_topics_response][:topic]
      topics.is_a?(Array) ? topics : [topics]
    end

    # Returns a hash of channel info for the given channel
    # Arguments (Required)
    #   :channel_id
    #
    # WSDL: GetChannelInfo
    def self.get_channel_info(*args)
      validate_presense_of args, :channel_id
      response = client.request :wsdl, "GetChannelInfo" do
        soap.body = {
          "channelID" => args.first[:channel_id]
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
          "channelID" => args.first[:channel_id],
          "topic" => args.first[:topic_name]
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
      response = client.request :wsdl, "DeleteChannel" do
        soap.body = {
          "channelID" => args.first[:channel_id]
        }
      end
      response.to_hash[:delete_channel_response]
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
          "channelID" => args.first[:channel_id],
          "topic" => args.first[:topic]
        }
      end
      response.to_hash[:delete_topic_response]
    end

    # --------------------------------------------------------------------
    # The Following is Register specific ISBM functions and are not
    # related to functionality in the ISBM WSDL in any form
    # --------------------------------------------------------------------

    def self.delete_all_channels
      Isbm::ChannelManagement.get_all_channels.each do |id|
        client.request :wsdl, "DeleteChannel" do
          soap.body = {
            "channelID" => id
          }
        end
      end
    end

    def self.get_topics(id)
      channel_info = Isbm::ChannelManagement.get_channel_info :channel_id => id
      channel_info[:topic]
    end
  end
end
