require 'isbm-adaptor/service'
require 'isbm-adaptor/channel'

module IsbmAdaptor
  class ChannelManagement
    include IsbmAdaptor::Service

    # Creates a new ISBM ChannelManagement client.
    #
    # @param endpoint [String] the SOAP endpoint URI
    # @option options [Object] :logger (Rails.logger or $stdout) location where log should be output
    # @option options [Boolean] :log (true) specify whether requests are logged
    # @option options [Boolean] :pretty_print_xml (false) specify whether request and response XML are formatted
    def initialize(endpoint, options = {})
      options[:wsdl] = wsdl_dir + 'ISBMChannelManagementService.wsdl'
      options[:endpoint] = endpoint
      default_savon_options(options)
      @client = Savon.client(options)
    end

    # Creates a new channel.
    #
    # @param uri [String] the channel URI
    # @param type [Symbol] the channel type, either :publication or :request
    # @param description [String] the channel description, defaults to nil
    # @return [void]
    # @raise [ArgumentError] if uri or type are nil/empty or type is not a valid Symbol
    def create_channel(uri, type, description = nil)
      validate_presence_of uri, type
      raise ArgumentError, "#{type} is not a valid type. Must be either :publication or :request." unless IsbmAdaptor::Channel::TYPES.has_key?(type)

      message = { 'ChannelURI' => uri,
                  'ChannelType' => IsbmAdaptor::Channel::TYPES[type] }
      message['ChannelDescription'] = description  unless description.nil?

      @client.call(:create_channel, message: message)

      return true
    end

    # Deletes the specified channel.
    #
    # @param uri [String] the channel URI
    # @return [void]
    # @raise [ArgumentError] if uri is nil/empty
    def delete_channel(uri)
      validate_presence_of uri

      @client.call(:delete_channel, message: { 'ChannelURI' => uri })

      return true
    end

    # Gets information about the specified channel
    #
    # @param uri [String] the channel URI
    # @return [Channel] the queried channel
    # @raise [ArgumentError] if uri is nil/empty
    def get_channel(uri)
      validate_presence_of uri

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
