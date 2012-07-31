require "isbm/validation"
require "isbm/channel"

module Isbm
  class ChannelManagement
    extend Savon::Model
    include Isbm

    class << self
      include Isbm::Validation
    end

    document Isbm.wsdl_dir + "ISBMChannelManagementService.wsdl"
    endpoint Isbm::Config.channel_management_endpoint

    # Creates a new channel
    # 'type' must be either :publication, :request or :response
    def self.create_channel(uri, type, description = nil)
      validate_presence_of uri, type
      raise ArgumentError.new "#{type} is not a valid type. Must be either :publication, :request or :response." unless Isbm::Channel::TYPES.has_key?(type)
      client.request :wsdl, :create_channel do
        set_default_namespace soap
        xml = Builder::XmlMarkup.new # Use separate builder when using conditional statements in XML generation
        xml.ChannelURI(uri)
        xml.ChannelType(Isbm::Channel::TYPES[type])
        xml.ChannelDescription(description) unless description.nil?
        soap.body = xml.target!
      end
      return true
    end

    # Deletes the specified channel
    def self.delete_channel(uri)
      validate_presence_of uri
      client.request :wsdl, :delete_channel do
        set_default_namespace soap
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
      response = client.request :wsdl, :get_channel do
        set_default_namespace soap
        soap.body do |xml|
          xml.ChannelURI(uri)
        end
      end
      hash = response.to_hash[:get_channel_response][:channel]
      Isbm::Channel.from_hash(hash)
    end

    # Gets information about all channels
    # Returns an array of channels
    def self.get_channels
      response = client.request :wsdl, :get_channels
      channels = response.to_hash[:get_channels_response][:channel]
      channels = [channels].compact unless channels.is_a?(Array)
      channels.map do |hash|
        Isbm::Channel.from_hash(hash)
      end
    end
  end
end
