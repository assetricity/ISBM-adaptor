require "isbm-adaptor/validation"
require "isbm-adaptor/message"

module IsbmAdaptor
  class ConsumerPublication
    extend Savon::Model
    include IsbmAdaptor

    class << self
      include IsbmAdaptor::Validation
    end

    document wsdl_dir + "ISBMConsumerPublicationService.wsdl"
    endpoint IsbmAdaptor::Config.consumer_publication_endpoint

    # Opens a subscription session for a channel
    # 'topics' must be an array of topic strings
    # Returns the session id
    def self.open_session(uri, topics, listener_uri = nil)
      validate_presence_of uri, topics
      response = client.request :wsdl, :open_subscription_session do
        set_default_namespace soap
        xml = Builder::XmlMarkup.new # Use separate builder when using conditional statements in XML generation
        xml.ChannelURI(uri)
        topics.each do |topic|
          xml.Topic(topic)
        end
        xml.ListenerURI(listener_uri) unless listener_uri.nil?
        soap.body = xml.target!
      end
      response.to_hash[:open_subscription_session_response][:session_id].to_s
    end

    # Reads the first message after the specified last message
    # Setting last_message_id to nil will return the first publication
    # Returns a IsbmAdaptor::Message
    def self.read_publication(session_id, last_message_id)
      validate_presence_of session_id
      response = client.request :wsdl, :read_publication do
        set_default_namespace soap
        xml = Builder::XmlMarkup.new # Use separate builder when using conditional statements in XML generation
        xml.SessionID(session_id)
        xml.LastMessageID(last_message_id) unless last_message_id.nil?
        soap.body = xml.target!
      end
      hash = response.to_hash[:read_publication_response][:publication_message]
      message = nil
      if hash
        id = hash[:message_id]
        topics = hash[:topic]

        # Extract the child element in message content
        # //isbm:ReadPublicationResponse/isbm:PublicationMessage/isbm:MessageContent/child::*
        content = response.doc.root.element_children.first.element_children.first.element_children.first.element_children[1].element_children.first

        # Retain any ancestor namespaces in case they are applicable for the element and/or children
        # This is because content#to_xml does not output ancestor namespaces
        content.namespaces.each do |key, value|
          prefix = key.gsub(/xmlns:?/, "")
          prefix = nil if prefix.empty?
          content.add_namespace_definition(prefix, value)
        end

        message = IsbmAdaptor::Message.new(id, content, topics)
      end
      message
    end

    # Closes a subscription session
    def self.close_session(session_id)
      validate_presence_of session_id
      client.request :wsdl, :close_subscription_session do
        set_default_namespace soap
        soap.body do |xml|
          xml.SessionID(session_id)
        end
      end
      return true
    end
  end
end
