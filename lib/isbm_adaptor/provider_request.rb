require 'isbm_adaptor/client'

module IsbmAdaptor
  class ProviderRequest < IsbmAdaptor::Client

    # Creates a new ISBM ProviderRequest client.
    #
    # @param endpoint [String] the SOAP endpoint URI
    # @option options [Object] :logger (Rails.logger or $stdout) location where log should be output
    # @option options [Boolean] :log (true) specify whether requests are logged
    # @option options [Boolean] :pretty_print_xml (false) specify whether request and response XML are formatted
    def initialize(endpoint, options = {})
      super('ProviderRequestService.wsdl', endpoint, options)
    end

    # Opens a provider request session for a channel for reading requests and
    # posting responses.
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

      response = @client.call(:open_provider_request_session, message: xml.target!)

      response.to_hash[:open_provider_request_session_response][:session_id].to_s
    end

    # Returns the first request message in the message queue for the session.
    # Note: this service does not remove the message from the message queue.
    #
    # @param session_id [String] the session id
    # @return [Message] the first message in the queue for the session.
    #   nil if no message.
    # @raise [ArgumentError] if session_id is blank
    def read_request(session_id)
      validate_presence_of session_id, 'Session Id'

      message = { 'SessionID' => session_id }
      response = @client.call(:read_request, message: message)

      extract_message(response)
    end

    # Deletes the first request message, if any, in the message queue for the session.
    #
    # @param session_id [String] the session id
    # @return [void]
    # @raise [ArgumentError] if session_id is blank
    def remove_request(session_id)
      validate_presence_of session_id, 'Session Id'

      @client.call(:remove_request, message: { 'SessionID' => session_id })

      return true
    end

    # Posts a response message on a channel.
    #
    # @param session_id [String] the session id
    # @param request_message_id [String] the id of the original request message
    # @param content [String] a valid XML string as message contents
    # @return [String] the response message id
    # @raise [ArgumentError] if session_id, request_message_id or content are
    #   blank, or content is not valid XML
    def post_response(session_id, request_message_id, content)
      validate_presence_of session_id, 'Session Id'
      validate_presence_of request_message_id, 'Request Message Id'
      validate_presence_of content, 'Content'
      validate_xml content

      # Use Builder to generate XML body as we need to concatenate XML message content
      xml = Builder::XmlMarkup.new
      xml.isbm :SessionID, session_id
      xml.isbm :RequestMessageID, request_message_id
      xml.isbm :MessageContent do
        xml << content
      end

      response = @client.call(:post_response, message: xml.target!)

      response.to_hash[:post_response_response][:message_id].to_s
    end

    # Closes a provider request session.
    #
    # @param session_id [String] the session id
    # @return [void]
    # @raise [ArgumentError] if session_id is blank
    def close_session(session_id)
      validate_presence_of session_id, 'Session Id'

      @client.call(:close_provider_request_session, message: { 'SessionID' => session_id })

      return true
    end
  end
end
