module Isbm
  class ConsumerPublication
    include Savon::Model
    include Isbm

    document Isbm.wsdl_dir + "ISBMConsumerPublicationService.wsdl"
    endpoint Isbm::Config.consumer_publication_endpoint

    # Opens a subscription session for a channel
    # 'topics' must be an array of topic strings
    # Returns the session id
    def self.open_session(uri, topics, listener_uri = nil)
      validate_presence_of uri, topics
      response = client.request :wsdl, :open_subscription_session do
        set_default_namespace soap
        soap.body do |xml|
          xml.ChannelURI(uri)
          topics.each do |topic|
            xml.Topic(topic)
          end
          xml.ListenerURI(listener_uri) unless listener_uri.nil?
          xml # Last line of block needs to return Builder object
        end
      end
      response.to_hash[:open_subscription_session_response][:session_id]
    end

    # Reads the first message after the specified last message
    # Setting last_message_id to nil will return the first publication
    # Returns the publication message or nil if there isn't one available
    def self.read_publication(session_id, last_message_id)
      validate_presence_of session_id, last_message_id
      response = client.request :wsdl, :read_publication do
        set_default_namespace soap
        xml = Builder::XmlMarkup.new # Use separate builder when using conditional statements in XML generation
        xml.SessionID(session_id)
        xml.LastMessageID(last_message_id) unless last_message_id.nil?
        soap.body = xml.target!
      end
      response.to_hash[:read_publication_response][:publication_message]
    end

    # Closes a subscription session
    def self.close_session(session_id)
      validate_presence_of session_id
      response = client.request :wsdl, :close_subscription_session do
        set_default_namespace soap
        soap.body do |xml|
          xml.SessionID(session_id)
        end
      end
      return true
    end
  end
end
