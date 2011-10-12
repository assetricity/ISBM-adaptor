module Isbm
  class ProviderPublication
    include Isbm

    # Create a publication channel
    # Arguments (Required)
    #   :channel_id
    #
    # WSDL: OpenPublication
    def self.open_publication(*args)
      validate_presense_of args, :channel_id
      response = isbm_provider_pub.request :wsdl, "OpenPublication" do
        soap.body = {
          "channelID" => args.first[:channel_id]
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
      response = isbm_provider_pub.request :wsdl, "ClosePublication" do
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
      response = isbm_provider_pub.request :wsdl, "PostPublication" do
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
