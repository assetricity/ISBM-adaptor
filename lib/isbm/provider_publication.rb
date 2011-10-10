module Isbm
  class ProviderPublication
    include Isbm

    # Create a publication channel
    # Arguments (Required)
    #   :channel_id
    #
    # WSDL: OpenPublication
    def self.open_publication(*args)
      response = isbm_provider_pub.request :wsdl, "OpenPublication" do
        soap.body = {
          "channelID" => args.first[:channel_id]
        }
      end
      response.to_hash[:open_publication_response]
    end
  end
end
