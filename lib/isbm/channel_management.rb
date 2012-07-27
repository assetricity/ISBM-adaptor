module Isbm
  class ChannelManagement
    include Savon::Model
    include Isbm

    document  Isbm.wsdl_dir + "ISBMChannelManagementService.wsdl"
    endpoint  Isbm::Config.channel_management_endpoint

    # Creates a new channel
    # 'type' must be either :publication, :request or :response
    def self.create_channel(uri, type, description = nil)
      validate_presence_of uri, type
      raise ArgumentError.new "#{type} is not a valid type. Must be either :publication, :request or :response." unless self.channel_types.has_key? type
      response = client.request :wsdl, "CreateChannel" do
        soap.body do |xml|
          xml.ChannelURI(uri)
          xml.ChannelType(channel_types[type])
          xml.ChannelDescription(description) unless description.nil?
        end
      end
      return true
    end

    # Deletes the specified channel
    def self.delete_channel(uri)
      validate_presence_of uri
      response = client.request :wsdl, "DeleteChannel" do
        soap.body do |xml|
          xml.ChannelURI(uri)
        end
      end
      return true
    end

    # Gets information about the specified channel
    # Returns a single channel
    def self.get_channel(uri)
      validate_presence_of uri
      response = client.request :wsdl, "GetChannel" do
        soap.body do |xml|
          xml.ChannelURI(uri)
        end
      end
      response.to_hash[:get_channel_response][:channel]
    end

    # Gets information about all channels
    # Returns an array of channels
    def self.get_channels
      response = client.request :wsdl, "GetChannels"
      channels = response.to_hash[:get_channels_response][:channel]
      channels.is_a?(Array) ? channels.compact : [channels].compact
    end

    private

    def self.channel_types
      @@channel_types ||= { :publication => "Publication", :request => "Request", :response => "Response" }
    end
  end
end
