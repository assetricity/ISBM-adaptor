require 'isbm_adaptor/service'
require 'isbm_adaptor/message'

module IsbmAdaptor
  class ConsumerPublication
    include IsbmAdaptor::Service

    # Creates a new ISBM ConsumerPublication client.
    #
    # @param endpoint [String] the SOAP endpoint URI
    # @option options [Object] :logger (Rails.logger or $stdout) location where log should be output
    # @option options [Boolean] :log (true) specify whether requests are logged
    # @option options [Boolean] :pretty_print_xml (false) specify whether request and response XML are formatted
    def initialize(endpoint, options = {})
      options[:wsdl] = wsdl_dir + 'ISBMConsumerPublicationService.wsdl'
      options[:endpoint] = endpoint
      default_savon_options(options)
      @client = Savon.client(options)
    end

    # Opens a subscription session for a channel.
    #
    # @param uri [String] the channel URI
    # @param topics [Array<String>] an array of topics
    # @param listener_uri [String] the URI for notification callbacks
    # @return [String] the session id
    # @raise [ArgumentError] if uri or topics are nil/empty
    def open_session(uri, topics, listener_uri = nil)
      validate_presence_of uri, 'Channel URI'
      validate_presence_of topics, 'Topics'

      # Use Builder to generate XML body as we may have multiple Topic elements
      xml = Builder::XmlMarkup.new
      xml.isbm :ChannelURI, uri
      topics.each do |topic|
        xml.isbm :Topic, topic
      end
      xml.isbm :ListenerURI, listener_uri unless listener_uri.nil?

      response = @client.call(:open_subscription_session, message: xml.target!)

      response.to_hash[:open_subscription_session_response][:session_id].to_s
    end

    # Reads the first message after the specified last message in the message
    # queue.
    #
    # @param session_id [String] the session id
    # @param last_message_id [String] the id of the last message. When set to
    #   nil, returns the first publication in the message queue
    # @return [Message] first message after specified last message. nil if no message.
    # @raise [ArgumentError] if session_id is nil/empty
    def read_publication(session_id, last_message_id)
      validate_presence_of session_id, 'Session Id'

      message = { 'SessionID' => session_id }
      message['LastMessageID'] = last_message_id unless last_message_id.nil?

      response = @client.call(:read_publication, message: message)

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
          prefix = key.gsub(/xmlns:?/, '')
          prefix = nil if prefix.empty?
          content.add_namespace_definition(prefix, value)
        end

        message = IsbmAdaptor::Message.new(id, content, topics)
      end
      message
    end

    # Closes a subscription session.
    #
    # @param session_id [String] the session id
    # @return [void]
    # @raise [ArgumentError] if session_id is nil/empty
    def close_session(session_id)
      validate_presence_of session_id, 'Session Id'

      @client.call(:close_subscription_session, message: { 'SessionID' => session_id })

      return true
    end
  end
end
