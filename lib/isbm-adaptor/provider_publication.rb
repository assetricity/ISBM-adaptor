require 'isbm-adaptor/service'
require 'isbm-adaptor/duration'

module IsbmAdaptor
  class ProviderPublication
    include IsbmAdaptor::Service

    # Creates a new ISBM ProviderPublication client.
    #
    # @param endpoint [String] the SOAP endpoint URI
    # @option options [Object] :logger (Rails.logger or $stdout) location where log should be output
    # @option options [Boolean] :log (true) specify whether requests are logged
    # @option options [Boolean] :pretty_print_xml (false) specify whether request and response XML are formatted
    def initialize(endpoint, options = {})
      options[:wsdl] = wsdl_dir + 'ISBMProviderPublicationService.wsdl'
      options[:endpoint] = endpoint
      default_savon_options(options)
      @client = Savon.client(options)
    end

    # Opens a publication session for a channel.
    #
    # @param [String] uri the channel URI
    # @return [String] the session id
    # @raise [ArgumentError] if uri is nil/empty
    def open_session(uri)
      validate_presence_of uri, 'Channel URI'

      response = @client.call(:open_publication_session, message: { 'ChannelURI' => uri })

      response.to_hash[:open_publication_session_response][:session_id].to_s
    end

    # Posts a publication message.
    #
    # @param content [String] a valid XML string as message contents
    # @param topics [Array<String>, String] a collection of topics or single topic
    # @param expiry [Duration] when the message should expire
    # @return [String] the message id
    # @raise [ArgumentError] if session_id, content, topics is nil/empty or content is not valid XML
    def post_publication(session_id, content, topics, expiry = nil)
      validate_presence_of session_id, 'Session Id'
      validate_presence_of content, 'Content'
      validate_presence_of topics, 'Topics'
      validate_xml content

      topics = [topics] unless topics.is_a?(Array)

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
