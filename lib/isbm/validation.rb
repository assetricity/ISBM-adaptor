module Isbm
  module Validation
    def validate_presence_of(*args)
      args.each_with_index do |arg, index|
        if arg.nil?
          raise ArgumentError.new "Argument #{index} is nil: #{args.inspect}"
        elsif arg.is_a?(Array) && arg.empty?
          raise ArgumentError.new "Array (argument #{index}) is empty: #{args.inspect}"
        end
      end
    end

    def validate_xml(xml)
      doc = Nokogiri.XML(xml)
      raise ArgumentError.new "XML is not well formed: #{xml}" unless doc.errors.empty?
    end
  end
end
