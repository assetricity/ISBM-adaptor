require 'isbm_adaptor/client'
require 'isbm_adaptor/channel'

module IsbmAdaptor
  class ChannelManagement < IsbmAdaptor::Client
    # Creates a new ISBM ChannelManagement client.
    #
    # @param endpoint [String] the SOAP endpoint URI
    # @option options [Object] :logger (Rails.logger or $stdout) location where log should be output
    # @option options [Boolean] :log (true) specify whether requests are logged
    # @option options [Boolean] :pretty_print_xml (false) specify whether request and response XML are formatted
    def initialize(endpoint, options = {})
      super('ISBMChannelManagementService.wsdl', endpoint, options)
    end

    # Creates a new channel.
    #
    # @param uri [String] the channel URI
    # @param type [Symbol] the channel type, either publication or request (symbol or titleized string)
    # @param description [String] the channel description, defaults to nil
    # @return [void]
    # @raise [ArgumentError] if uri or type are blank or type is not a valid Symbol
    def create_channel(uri, type, description = nil)
      validate_presence_of uri, 'Channel URI'
      validate_presence_of type, 'Channel Type'
      channel_type = type.to_s.downcase.capitalize
      raise ArgumentError, "#{channel_type} is not a valid type. Must be either Publication or Request." unless IsbmAdaptor::Channel::TYPES.include?(channel_type)

      message = { 'ChannelURI' => uri,
                  'ChannelType' => channel_type }
      message['ChannelDescription'] = description  unless description.nil?

      @client.call(:create_channel, message: message)

      return true
    end

    # Deletes the specified channel.
    #
    # @param uri [String] the channel URI
    # @return [void]
    # @raise [ArgumentError] if uri is blank
    def delete_channel(uri)
      validate_presence_of uri, 'Channel URI'

      @client.call(:delete_channel, message: { 'ChannelURI' => uri })

      return true
    end

    # Gets information about the specified channel
    #
    # @param uri [String] the channel URI
    # @return [Channel] the queried channel
    # @raise [ArgumentError] if uri is blank
    def get_channel(uri)
      validate_presence_of uri, 'Channel URI'

      response = @client.call(:get_channel, message: { 'ChannelURI' => uri })

      hash = response.to_hash[:get_channel_response][:channel]
      IsbmAdaptor::Channel.from_hash(hash)
    end

    # Gets information about all channels
    #
    # @return [Array<Channel>] all channels on the ISBM
    def get_channels
      response = @client.call(:get_channels)

      channels = response.to_hash[:get_channels_response][:channel]
      channels = [channels].compact unless channels.is_a?(Array)
      channels.map do |hash|
        IsbmAdaptor::Channel.from_hash(hash)
      end
    end
  end
end
