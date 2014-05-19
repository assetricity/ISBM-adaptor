require 'isbm_adaptor/client'
require 'isbm_adaptor/channel'

module IsbmAdaptor
  class ChannelManagement < IsbmAdaptor::Client
    # Creates a new ISBM ChannelManagement client.
    #
    # @param endpoint [String] the SOAP endpoint URI
    # @option options [Array<String>] :wsse_auth username and password, i.e. [username, password]
    # @option options [Object] :logger (Rails.logger or $stdout) location where log should be output
    # @option options [Boolean] :log (true) specify whether requests are logged
    # @option options [Boolean] :pretty_print_xml (false) specify whether request and response XML are formatted
    def initialize(endpoint, options = {})
      super('ChannelManagementService.wsdl', endpoint, options)
    end

    # Creates a new channel.
    #
    # @param uri [String] the channel URI
    # @param type [Symbol] the channel type, either publication or request (symbol or titleized string)
    # @param description [String] the channel description, defaults to nil
    # @param tokens [Hash] username password pairs, e.g. {'u1' => 'p1', 'u2' => 'p2'}
    # @return [void]
    # @raise [ArgumentError] if uri or type are blank or type is not a valid Symbol
    def create_channel(uri, type, description = nil, tokens = {})
      validate_presence_of uri, 'Channel URI'
      validate_presence_of type, 'Channel Type'
      channel_type = type.to_s.downcase.capitalize
      raise ArgumentError, "#{channel_type} is not a valid type. Must be either Publication or Request." unless IsbmAdaptor::Channel::TYPES.include?(channel_type)

      message = { 'ChannelURI' => uri,
                  'ChannelType' => channel_type }
      message['ChannelDescription'] = description unless description.nil?
      message['SecurityToken'] = security_token_hash(tokens) if tokens.any?

      @client.call(:create_channel, message: message)

      return true
    end

    # Adds security tokens to a channel.
    #
    # @param uri [String] the channel URI
    # @param tokens [Hash] username password pairs, e.g. {'u1' => 'p1', 'u2' => 'p2'}
    # @return [void]
    # @raise [ArgumentError] if uri is blank or no tokens are provided
    def add_security_tokens(uri, tokens = {})
      validate_presence_of uri, 'Channel URI'
      validate_presence_of tokens, 'Security Tokens'

      message = { 'ChannelURI' => uri,
                  'SecurityToken' => security_token_hash(tokens) }

      @client.call(:add_security_tokens, message: message)

      return true
    end

    # Removes security tokens from a channel.
    #
    # @param uri [String] the channel URI
    # @param tokens [Hash] username password pairs, e.g. {'u1' => 'p1', 'u2' => 'p2'}
    # @return [void]
    # @raise [ArgumentError] if uri is blank or no tokens are provided
    def remove_security_tokens(uri, tokens = {})
      validate_presence_of uri, 'Channel URI'
      validate_presence_of tokens, 'Security Tokens'

      message = { 'ChannelURI' => uri,
                  'SecurityToken' => security_token_hash(tokens) }

      @client.call(:remove_security_tokens, message: message)

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

    # Gets information about the specified channel.
    #
    # @param uri [String] the channel URI
    # @yield locals local options, including :wsse_auth
    # @return [Channel] the queried channel
    # @raise [ArgumentError] if uri is blank
    def get_channel(uri, &block)
      validate_presence_of uri, 'Channel URI'

      response = @client.call(:get_channel, message: { 'ChannelURI' => uri }, &block)

      hash = response.to_hash[:get_channel_response][:channel]
      IsbmAdaptor::Channel.from_hash(hash)
    end

    # Gets information about all channels.
    #
    # @yield locals local options, including :wsse_auth
    # @return [Array<Channel>] all authorized channels on the ISBM
    def get_channels(&block)
      response = @client.call(:get_channels, {}, &block)

      channels = response.to_hash[:get_channels_response][:channel]
      channels = [channels].compact unless channels.is_a?(Array)
      channels.map do |hash|
        IsbmAdaptor::Channel.from_hash(hash)
      end
    end

    private
    # Returns tokens mapped to wsse:UsernameToken hash.
    def security_token_hash(tokens)
      wsse = Akami.wsse
      tokens.map do |username, password|
        wsse.credentials(username, password)
        # Extract the UsernameToken element
        username_token = wsse.send(:wsse_username_token)['wsse:Security']
        # Restore the wsse namespace
        ns = {'xmlns:wsse' => Akami::WSSE::WSE_NAMESPACE}
        username_token[:attributes!]['wsse:UsernameToken'].merge!(ns)
        username_token
      end
    end
  end
end
