require "isbm-adaptor/validation"
require "isbm-adaptor/duration"

module IsbmAdaptor
  class ProviderPublication
    extend Savon::Model
    include IsbmAdaptor

    class << self
      include IsbmAdaptor::Validation
    end

    document wsdl_dir + "ISBMProviderPublicationService.wsdl"
    endpoint IsbmAdaptor::Config.provider_publication_endpoint

    # Opens a publication session for a channel
    # Returns the session id
    def self.open_session(uri)
      validate_presence_of uri
      response = client.request :wsdl, :open_publication_session do
        set_default_namespace soap
        soap.body do |xml|
          xml.ChannelURI(uri)
        end
      end
      response.to_hash[:open_publication_session_response][:session_id].to_s
    end

    # Posts a publication message
    # 'content' must be a valid XML string
    # 'topics' must be an array of topic strings or a single string
    # 'expiry', if specified, must be an IsbmAdaptor::Duration object
    # Returns the message id
    def self.post_publication(session_id, content, topics, expiry = nil)
      validate_presence_of session_id, content, topics
      validate_xml content
      topics = [topics] unless topics.is_a?(Array)
      response = client.request :wsdl, :post_publication do
        set_default_namespace soap
        xml = Builder::XmlMarkup.new # Use separate builder when using conditional statements in XML generation
        xml.SessionID(session_id)
        xml.MessageContent do
          xml << content
        end
        topics.each do |topic|
          xml.Topic(topic)
        end
        duration = expiry.to_s
        xml.Expiry(duration) unless duration.nil?
        soap.body = xml.target!
      end
      response.to_hash[:post_publication_response][:message_id].to_s
    end

    # Expires a posted publication message
    def self.expire_publication(session_id, message_id)
      validate_presence_of session_id, message_id
      client.request :wsdl, :expire_publication do
        set_default_namespace soap
        soap.body do |xml|
          xml.SessionID(session_id)
          xml.MessageID(message_id)
        end
      end
      return true
    end

    # Closes a publication session
    def self.close_session(session_id)
      validate_presence_of session_id
      client.request :wsdl, :close_publication_session do
        set_default_namespace soap
        soap.body do |xml|
          xml.SessionID(session_id)
        end
      end
      return true
    end
  end
end
