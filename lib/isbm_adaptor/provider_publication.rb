require 'isbm_adaptor/client'
require 'isbm_adaptor/duration'

module IsbmAdaptor
  class ProviderPublication < IsbmAdaptor::Client

    # Creates a new ISBM ProviderPublication client.
    #
    # @param endpoint [String] the SOAP endpoint URI
    # @option options [Object] :logger (Rails.logger or $stdout) location where log should be output
    # @option options [Boolean] :log (true) specify whether requests are logged
    # @option options [Boolean] :pretty_print_xml (false) specify whether request and response XML are formatted
    def initialize(endpoint, options = {})
      super('ISBMProviderPublicationService.wsdl', endpoint, options)
    end

    # Opens a publication session for a channel.
    #
    # @param uri [String] the channel URI
    # @return [String] the session id
    # @raise [ArgumentError] if uri is nil/empty
    def open_session(uri)
      validate_presence_of uri, 'Channel URI'

      response = @client.call(:open_publication_session, message: { 'ChannelURI' => uri })

      response.to_hash[:open_publication_session_response][:session_id].to_s
    end

    # Posts a publication message.
    #
    # @param session_id [String] the session id
    # @param content [String] a valid XML string as message contents
    # @param topics [Array<String>, String] a collection of topics or single topic
    # @param expiry [Duration] when the message should expire
    # @return [String] the message id
    # @raise [ArgumentError] if session_id, content or topics are nil/empty, or
    #   content is not valid XML
    def post_publication(session_id, content, topics, expiry = nil)
      validate_presence_of session_id, 'Session Id'
      validate_presence_of content, 'Content'
      validate_presence_of topics, 'Topics'
      validate_xml content

      topics = [topics].flatten

      # Use Builder to generate XML body as we need to concatenate XML message content
      xml = Builder::XmlMarkup.new
      xml.isbm :SessionID, session_id
      xml.isbm :MessageContent do
        xml << content
      end
      topics.each do |topic|
        xml.isbm :Topic, topic
      end
      duration = expiry.to_s
      xml.isbm :Expiry, duration unless duration.nil?

      response = @client.call(:post_publication, message: xml.target!)

      response.to_hash[:post_publication_response][:message_id].to_s
    end

    # Expires a posted publication message.
    #
    # @param session_id [String] the session id used to post the publication
    # @param message_id [String] the message id received after posting the publication
    # @return [void]
    # @raise [ArgumentError] if session_id or message_id are nil/empty
    def expire_publication(session_id, message_id)
      validate_presence_of session_id, 'Session Id'
      validate_presence_of message_id, 'Message Id'

      @client.call(:expire_publication, message: { 'SessionID' => session_id, 'MessageID' => message_id })

      return true
    end

    # Closes a publication session.
    #
    # @param session_id [String] the session id
    # @return [void]
    # @raise [ArgumentError] if session_id is nil/empty
    def close_session(session_id)
      validate_presence_of session_id, 'Session Id'

      @client.call(:close_publication_session, message: { 'SessionID' => session_id })

      return true
    end
  end
end
