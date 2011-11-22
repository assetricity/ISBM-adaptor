module Isbm
  class ConsumerPublication
    include Isbm
    include Savon::Model
    document Isbm.wsdl_dir + "ISBMConsumerPublicationService.wsdl"
    endpoint Isbm::Config.consumer_publication_endpoint

    def self.open_subscription(*args)
      validate_presense_of args, :channel_id, :topic_name
      response = client.request :wsdl, "OpenSubscriptionSession" do
        soap.body = {
          :channel_i_d => args.first[:channel_id],
          :topic_name => args.first[:topic_name],
          :listener_u_r_i => args.first[:listener_uri]
        }
      end
      response.to_hash[:open_subscription_session_response]
    end

    def self.close_subscription(*args)
      validate_presense_of args, :session_id
      response = client.request :wsdl, "CloseSubscriptionSession" do
        soap.body = {
          :session_i_d => args.first[:session_id]
        }
      end
      response.to_hash[:close_subscription_session_response]
    end

    def self.read_publication(*args)
      validate_presense_of args, :session_id
      response = client.request :wsdl, "ReadPublication" do
        soap.body = {
          :session_i_d => args.first[:session_id]
        }
      end
      response.to_hash[:read_publication_response]
    end
  end
end
