module Isbm
  class ProviderPublication
    include Isbm
    include Savon::Model
    document "wsdls/ISBMChannelManagementService.wsdl"
    endpoint  "http://172.16.72.31:9080/IsbmModuleWeb/sca/ISBMProviderPublicationServiceSoapExport"

    # Create a publication channel
    # Arguments (Required)
    #   :channel_id
    #
    # WSDL: OpenPublication
    def self.open_publication(*args)
      validate_presense_of args, :channel_id
      response = client.request :wsdl, "OpenPublication" do
        soap.body = {
          :channel_i_d => args.first[:channel_id]
        }
      end
      response.to_hash[:open_publication_response]
    end

    # Close an open publication channel
    # Arguments (Required)
    #   :channel_session_id
    #
    # WSDL: ClosePublication
    def self.close_publication(*args)
      validate_presense_of args, :channel_session_id
      response = client.request :wsdl, "ClosePublication" do
        soap.body = {
          "channelSessionID" => args.first[:channel_session_id]
        }
      end
      response.to_hash[:close_publication_response]
    end

    # Post a message to a publication channel
    # Arguments (Required)
    #   :channel_session_id
    #   :topic
    #   :publication_message
    #
    # WSDL: PostPublication
    def self.post_publication(*args)
      validate_presense_of args, :channel_session_id, :topic, :publication_message
      response = client.request :wsdl, "PostPublication" do
        soap.body = {
          "channelSessionID" => args.first[:channel_session_id],
          "topic" => args.first[:topic],
          "PublicationMessage" => args.first[:publication_message]
        }
      end
      response.to_hash[:post_publication_response]
    end
  end
end
