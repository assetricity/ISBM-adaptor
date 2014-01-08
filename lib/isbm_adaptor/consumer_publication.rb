require 'isbm_adaptor/client'

module IsbmAdaptor
  class ConsumerPublication < IsbmAdaptor::Client

    # Creates a new ISBM ConsumerPublication client.
    #
    # @param endpoint [String] the SOAP endpoint URI
    # @option options [Object] :logger (Rails.logger or $stdout) location where log should be output
    # @option options [Boolean] :log (true) specify whether requests are logged
    # @option options [Boolean] :pretty_print_xml (false) specify whether request and response XML are formatted
    def initialize(endpoint, options = {})
      super('ConsumerPublicationService.wsdl', endpoint, options)
    end

    # Opens a subscription session for a channel.
    #
    # @param uri [String] the channel URI
    # @param topics [Array<String>] an array of topics
    # @param listener_url [String] the URL for notification callbacks
    # @param xpath_expression [String] the XPath filter expression
    # @param xpath_namespaces [Array<Hash>] the prefixes and namespaces used by the XPath expression. The hash key
    #   represents the namespace prefix while the value represents the namespace name. For example,
    #   ["xs" => "http://www.w3.org/2001/XMLSchema", "isbm" => "http://www.openoandm.org/xml/ISBM/"]
    # @return [String] the session id
    # @raise [ArgumentError] if uri or topics are blank
    def open_session(uri, topics, listener_url = nil, xpath_expression = nil, xpath_namespaces = [])
      validate_presence_of uri, 'Channel URI'
      validate_presence_of topics, 'Topics'
      validate_presence_of xpath_expression, 'XPath Expression' if xpath_namespaces.present?

      # Use Builder to generate XML body as we may have multiple Topic elements
      xml = Builder::XmlMarkup.new
      xml.isbm :ChannelURI, uri
      topics.each do |topic|
        xml.isbm :Topic, topic
      end
      xml.isbm :ListenerURL, listener_url unless listener_url.nil?
      xml.isbm :XPathExpression, xpath_expression unless xpath_expression.nil?
      xpath_namespaces.each do |prefix, name|
        xml.isbm :XPathNamespace do
          xml.isbm :NamespacePrefix, prefix
          xml.isbm :NamespaceName, name
        end
      end

      response = @client.call(:open_subscription_session, message: xml.target!)

      response.to_hash[:open_subscription_session_response][:session_id].to_s
    end

    # Reads the first message, if any, in the session queue.
    #
    # @param session_id [String] the session id
    # @return [Message] first message in session queue. nil if no message.
    # @raise [ArgumentError] if session_id is blank
    def read_publication(session_id)
      validate_presence_of session_id, 'Session Id'

      response = @client.call(:read_publication, message: { 'SessionID' => session_id })

      extract_message(response)
    end

    # Removes the first message, if any, in the session queue.
    #
    # @param session_id [String] the session id
    # @return [void]
    # @raise [ArgumentError] if session_id is blank
    def remove_publication(session_id)
      validate_presence_of session_id, 'Session Id'

      @client.call(:remove_publication, message: { 'SessionID' => session_id })

      return true
    end

    # Closes a subscription session.
    #
    # @param session_id [String] the session id
    # @return [void]
    # @raise [ArgumentError] if session_id is blank
    def close_session(session_id)
      validate_presence_of session_id, 'Session Id'

      @client.call(:close_subscription_session, message: { 'SessionID' => session_id })

      return true
    end
  end
end
