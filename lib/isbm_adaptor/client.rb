require 'isbm_adaptor/message'

module IsbmAdaptor
  class Client
    # Creates a new ISBM client.
    #
    # @param wsdl_file [String] the filename of the WSDL
    # @param endpoint [String] the SOAP endpoint URI
    # @option options [Object] :logger (Rails.logger or $stdout) location where log should be output
    # @option options [Boolean] :log (true) specify whether requests are logged
    # @option options [Boolean] :pretty_print_xml (false) specify whether request and response XML are formatted
    def initialize(wsdl_file, endpoint, options = {})
      options[:wsdl] = wsdl_dir + wsdl_file
      options[:endpoint] = endpoint
      default_savon_options(options)
      @client = Savon.client(options)
    end

    # Validates the presence of the passed value.
    #
    # @param value [Object] presence of object to validate
    # @param name [String] name of value to include in error message if not present
    # @return [void]
    # @raise [ArgumentError] if value is not present
    def validate_presence_of(value, name)
      if value.respond_to?(:each)
        value.each do |v|
          if v.blank?
            raise ArgumentError, "Values in #{name} must not be blank"
          end
        end
      else
        if value.blank?
          raise ArgumentError, "#{name} must not be blank"
        end
      end
    end

    # Validates the well formedness of the XML string and raises an error if
    # any errors are encountered.
    #
    # @param xml [String] the XML string to parse
    # @return [void]
    def validate_xml(xml)
      doc = Nokogiri.XML(xml)
      raise ArgumentError, "XML is not well formed: #{xml}" unless doc.errors.empty?
    end

    # Creates an IsbmAdaptor::Message from a ISBM response.
    #
    # @param response [Savon::Response] the ISBM response
    # @return [IsbmAdaptor::Message] the extracted message
    def extract_message(response)
      # Extract the message element
      # e.g. /Envelope/Body/ReadPublicationResponse/PublicationMessage
      message = response.doc.root.first_element_child.first_element_child.first_element_child

      return nil unless message

      id = message.element_children[0].text
      content = message.element_children[1].first_element_child
      topics = message.element_children[2..-1].map {|e| e.text}

      # Retain any ancestor namespaces in case they are applicable for the element
      # and/or children. This is because content.to_xml does not output ancestor
      # namespaces.
      # There may be unnecessary namespaces carried across (e.g. ISBM, SOAP), but we
      # can't tell if the content uses them without parsing the content itself.
      content.namespaces.each do |key, value|
        # Don't replace default namespace if it already exists
        next if key == 'xmlns' && content['xmlns']
        content[key] = value
      end

      # Wrap content in a separate Nokogiri document. This allows the ability to
      # validate the content against a schema.
      doc = Nokogiri::XML(content.to_xml)

      IsbmAdaptor::Message.new(id, doc, topics)
    end

    private

    # Indicates the directory of the ISBM WSDL files
    #
    # @return [String] directory of ISBM WSDL files
    def wsdl_dir
      File.expand_path(File.dirname(__FILE__)) + '/../../wsdls/'
    end

    # Sets default values for certain Savon options.
    #
    # @param options [Hash] the options to set defaults on
    # @return [Hash] options hash with defaults set
    def default_savon_options(options)
      options[:logger] = Rails.logger if options[:logger].nil? && defined?(Rails)
      options[:log] = false if options[:log].nil?
      options[:pretty_print_xml] = true if options[:pretty_print_xml].nil?
    end
  end
end
