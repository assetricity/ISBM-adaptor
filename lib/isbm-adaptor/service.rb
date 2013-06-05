module IsbmAdaptor
  module Service
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
      options[:logger] = Rails.logger if defined?(Rails)
      options[:log] ||= true
      options[:pretty_print_xml] ||= false
    end

    # Validates the presence of the passed value.
    #
    # @param value [Object] presence of object to validate
    # @param name [String] name of value to include in error message if not present
    # @return [void]
    # @raises [ArgumentError] if value is not present
    def validate_presence_of(value, name)
      if value.blank?
        raise ArgumentError, "#{name} must be specified"
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
  end
end
