require "isbm-adaptor/validation"
require "isbm-adaptor/message"

module IsbmAdaptor
  class ConsumerPublication
    extend Savon::Model
    include IsbmAdaptor

    class << self
      include IsbmAdaptor::Validation
    end

    config = { wsdl: wsdl_dir + "ISBMConsumerPublicationService.wsdl",
               endpoint: IsbmAdaptor::Config.consumer_publication_endpoint,
               log: IsbmAdaptor::Config.log,
               pretty_print_xml: IsbmAdaptor::Config.pretty_print_xml }
    config[:logger] = Rails.logger if IsbmAdaptor::Config.use_rails_logger && defined?(Rails)

    client config

    operations :open_subscription_session, :read_publication, :close_subscription_session

    # Opens a subscription session for a channel
    # 'topics' must be an array of topic strings
    # Returns the session id
    def self.open_session(uri, topics, listener_uri = nil)
      validate_presence_of uri, topics

      # Use Builder to generate XML body as we may have multiple Topic elements
      xml = Builder::XmlMarkup.new
      xml.isbm :ChannelURI, uri
      topics.each do |topic|
        xml.isbm :Topic, topic
      end
      xml.isbm :ListenerURI, listener_uri unless listener_uri.nil?

      response = open_subscription_session(message: xml.target!)

      response.to_hash[:open_subscription_session_response][:session_id].to_s
    end

    # Reads the first message after the specified last message
    # Setting last_message_id to nil will return the first publication
    # Returns a IsbmAdaptor::Message
    def self.read_publication(session_id, last_message_id)
      validate_presence_of session_id

      message = { "SessionID" => session_id }
      message["LastMessageID"] = last_message_id unless last_message_id.nil?

      response = super(message: message)

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

      close_subscription_session(message: { "SessionID" => session_id })

      return true
    end
  end
end
