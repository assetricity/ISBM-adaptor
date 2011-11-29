module Isbm
  class ProviderPublication
    include Isbm
    include Savon::Model
    document Isbm.wsdl_dir + "ISBMChannelManagementService.wsdl"
    endpoint Isbm::Config.provider_publication_endpoint

    # Create a publication channel
    # Arguments (Required)
    #   :channel_id
    #
    # WSDL: OpenPublicationSession
    def self.open_publication(*args)
      validate_presense_of args, :channel_id
      response = client.request :wsdl, "OpenPublicationSession" do
        soap.body = {
          :channel_i_d => args.first[:channel_id]
        }
      end
      response.to_hash[:open_publication_session_response]
    end

    # Close an open publication channel
    # Arguments (Required)
    #   :channel_session_id
    #
    # WSDL: ClosePublication
    def self.close_publication(*args)
      validate_presense_of args, :channel_session_id
      response = client.request :wsdl, "ClosePublicationSession" do
        soap.body = {
          :session_i_d => args.first[:channel_session_id]
        }
      end
      response.to_hash[:close_publication_session_response]
    end

    # Post a message to a publication channel
    # Arguments (Required)
    #   :channel_session_id
    #   :topic_name
    #
    # WSDL: PostPublication
    def self.post_publication(*args)
      validate_presense_of args, :session_id, :topic_name, :message
      response = client.request :wsdl, "PostPublication" do
        soap.body = {
          :session_i_d => args.first[:session_id],
          :message_content! => args.first[:message],
          :topic_name => args.first[:topic_name]
        }
      end
      response.to_hash[:post_publication_response]
    end
  end
end
