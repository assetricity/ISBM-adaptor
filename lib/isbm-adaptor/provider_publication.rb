require "isbm-adaptor/validation"
require "isbm-adaptor/duration"

module IsbmAdaptor
  class ProviderPublication
    extend Savon::Model
    include IsbmAdaptor

    class << self
      include IsbmAdaptor::Validation
    end

    config = { wsdl: wsdl_dir + "ISBMProviderPublicationService.wsdl",
               endpoint: IsbmAdaptor::Config.provider_publication_endpoint,
               log: IsbmAdaptor::Config.log,
               pretty_print_xml: IsbmAdaptor::Config.pretty_print_xml }
    config[:logger] = Rails.logger if IsbmAdaptor::Config.use_rails_logger && defined?(Rails)

    client config

    operations :open_publication_session, :post_publication, :expire_publication, :close_publication_session

    # Opens a publication session for a channel
    # Returns the session id
    def self.open_session(uri)
      validate_presence_of uri

      response = open_publication_session(message: { "ChannelURI" => uri })

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

      response = super(message: xml.target!)

      response.to_hash[:post_publication_response][:message_id].to_s
    end

    # Expires a posted publication message
    def self.expire_publication(session_id, message_id)
      validate_presence_of session_id, message_id

      super(message: { "SessionID" => session_id, "MessageID" => message_id })

      return true
    end

    # Closes a publication session
    def self.close_session(session_id)
      validate_presence_of session_id

      close_publication_session(message: { "SessionID" => session_id })

      return true
    end
  end
end
