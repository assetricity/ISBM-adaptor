require "isbm-adaptor/validation"
require "isbm-adaptor/channel"

module IsbmAdaptor
  class ChannelManagement
    extend Savon::Model
    include IsbmAdaptor

    class << self
      include IsbmAdaptor::Validation
    end

    config = { wsdl: wsdl_dir + "ISBMChannelManagementService.wsdl",
               endpoint: IsbmAdaptor::Config.channel_management_endpoint,
               log: IsbmAdaptor::Config.log,
               pretty_print_xml: IsbmAdaptor::Config.pretty_print_xml }
    config[:logger] = Rails.logger if IsbmAdaptor::Config.use_rails_logger && defined?(Rails)

    client config

    operations :create_channel, :delete_channel, :get_channel, :get_channels

    # Creates a new channel
    # 'type' must be either :publication, :request or :response
    def self.create_channel(uri, type, description = nil)
      validate_presence_of uri, type
      raise ArgumentError.new "#{type} is not a valid type. Must be either :publication, :request or :response." unless IsbmAdaptor::Channel::TYPES.has_key?(type)

      message = { "ChannelURI" => uri,
                  "ChannelType" => IsbmAdaptor::Channel::TYPES[type] }
      message["ChannelDescription"] = description  unless description.nil?

      super(message: message)

      return true
    end

    # Deletes the specified channel
    def self.delete_channel(uri)
      validate_presence_of uri

      super(message: { "ChannelURI" => uri })

      return true
    end

    # Gets information about the specified channel
    # Returns a single channel
    def self.get_channel(uri)
      validate_presence_of uri

      response = super(message: { "ChannelURI" => uri })

      hash = response.to_hash[:get_channel_response][:channel]
      IsbmAdaptor::Channel.from_hash(hash)
    end

    # Gets information about all channels
    # Returns an array of channels
    def self.get_channels
      response = super

      channels = response.to_hash[:get_channels_response][:channel]
      channels = [channels].compact unless channels.is_a?(Array)
      channels.map do |hash|
        IsbmAdaptor::Channel.from_hash(hash)
      end
    end
  end
end
