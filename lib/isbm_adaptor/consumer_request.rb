require 'isbm_adaptor/client'

module IsbmAdaptor
  class ConsumerRequest < IsbmAdaptor::Client

    # Creates a new ISBM ConsumerRequest client.
    #
    # @param endpoint [String] the SOAP endpoint URI
    # @option options [Object] :logger (Rails.logger or $stdout) location where log should be output
    # @option options [Boolean] :log (true) specify whether requests are logged
    # @option options [Boolean] :pretty_print_xml (false) specify whether request and response XML are formatted
    def initialize(endpoint, options = {})
      super('ISBMConsumerRequestService.wsdl', endpoint, options)
    end

    # Opens a consumer request session for a channel for posting requests and
    # reading responses.
    #
    # @param uri [String] the channel URI
    # @param listener_uri [String] the URI for notification callbacks
    # @return [String] the session id
    # @raise [ArgumentError] if uri is blank
    def open_session(uri, listener_uri = nil)
      validate_presence_of uri, 'Channel URI'

      message = { 'ChannelURI' => uri }
      message['ListenerURI'] = listener_uri if listener_uri

      response = @client.call(:open_consumer_request_session, message: message)

      response.to_hash[:open_consumer_request_session_response][:session_id].to_s
    end

    # Posts a request message on a channel.
    #
    # @param session_id [String] the session id
    # @param content [String] a valid XML string as message contents
    # @param topic [String] the topic
    # @return [String] the request message id
    # @raise [ArgumentError] if session_id, content or topics are blank, or
    #   content is not valid XML
    def post_request(session_id, content, topic)
      validate_presence_of session_id, 'Session Id'
      validate_presence_of content, 'Content'
      validate_presence_of topic, 'Topic'
      validate_xml content

      # Use Builder to generate XML body as we need to concatenate XML message content
      xml = Builder::XmlMarkup.new
      xml.isbm :SessionID, session_id
      xml.isbm :MessageContent do
        xml << content
      end
      xml.isbm :Topic, topic

      response = @client.call(:post_request, message: xml.target!)

      response.to_hash[:post_request_response][:message_id].to_s
    end

    # Returns the first response message, if any, in the message queue
    # associated with the request.
    #
    # @param session_id [String] the session id
    # @param request_message_id [String] the id of the original request message
    # @return [Message] the first message in the queue for the session.
    #   nil if no message.
    # @raise [ArgumentError] if session_id or request_message_id are blank
    def read_response(session_id, request_message_id)
      validate_presence_of session_id, 'Session Id'
      validate_presence_of request_message_id, 'Request Message Id'

      message = { 'SessionID' => session_id, 'RequestMessageID' => request_message_id }
      response = @client.call(:read_response, message: message)

      extract_message(response)
    end

    # Deletes the first response message, if any, in the message queue
    # associated with the request.
    #
    # @param session_id [String] the session id
    # @param request_message_id [String] the id of the original request message
    # @return [void]
    # @raise [ArgumentError] if session_id is blank
    def remove_response(session_id, request_message_id)
      validate_presence_of session_id, 'Session Id'
      validate_presence_of request_message_id, 'Request Message Id'

      message = { 'SessionID' => session_id, 'RequestMessageID' => request_message_id }
      @client.call(:remove_response, message: message)

      return true
    end

    # Closes a consumer request session.
    #
    # @param session_id [String] the session id
    # @return [void]
    # @raise [ArgumentError] if session_id is blank
    def close_session(session_id)
      validate_presence_of session_id, 'Session Id'

      @client.call(:close_consumer_request_session, message: { 'SessionID' => session_id })

      return true
    end
  end
end
