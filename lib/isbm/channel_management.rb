module Isbm
  class ChannelManagement
    extend Savon::Model
    include Isbm

    document  Isbm.wsdl_dir + "ISBMChannelManagementService.wsdl"
    endpoint  Isbm::Config.channel_management_endpoint

    # Creates a new channel
    # 'type' must be either :publication, :request or :response
    def self.create_channel(uri, type, description = nil)
      validate_presence_of uri, type
      raise ArgumentError.new "#{type} is not a valid type. Must be either :publication, :request or :response." unless self.channel_types.has_key? type
      # TODO AM Why don't strings work for SOAP action?
      # TODO AM Why doesn't Builder pick up XML namespaces
      response = client.request :wsdl, :create_channel do
        body = { "ChannelURI" => uri, "ChannelType" => channel_types[type] }
        body.merge!({ "ChannelDescription" => description }) unless description.nil?
        soap.body = body
      end
      return true
    end

    # Deletes the specified channel
    def self.delete_channel(uri)
      validate_presence_of uri
      response = client.request :wsdl, :delete_channel do
        soap.namespaces["xmlns"] = "http://www.openoandm.org/xml/ISBM/"
        soap.body = { "ChannelURI" => uri }
      end
      return true
    end

    # Gets information about the specified channel
    # Returns a single channel
    def self.get_channel(uri)
      validate_presence_of uri
      response = client.request :wsdl, :get_channel do
        soap.body = { "ChannelURI" => uri }
      end
      response.to_hash[:get_channel_response][:channel]
    end

    # Gets information about all channels
    # Returns an array of channels
    def self.get_channels
      response = client.request :wsdl, :get_channels
      channels = response.to_hash[:get_channels_response][:channel]
      channels.is_a?(Array) ? channels.compact : [channels].compact
    end

    private

    def self.channel_types
      @@channel_types ||= { :publication => "Publication", :request => "Request", :response => "Response" }
    end
  end
end
