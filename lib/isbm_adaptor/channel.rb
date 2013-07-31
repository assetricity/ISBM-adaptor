module IsbmAdaptor
  class Channel
    TYPES = ['Publication', 'Request']

    attr_accessor :uri, :type, :description

    # Creates a new Channel.
    #
    # @param uri [String] the channel URI
    # @param type [String] the channel type, either 'Publication' or 'Request'
    # @param description [String] the channel description
    def initialize(uri, type, description)
      @uri = uri.to_s
      @type = type
      @description = description.to_s unless description.nil?
    end

    # Creates a new Channel based on a hash.
    #
    # @options hash [String] :channel_uri the channel URI
    # @options hash [String] :channel_type the channel type, either 'Publication' or 'Request'
    # @options hash [String] :channel_description the channel description
    def self.from_hash(hash)
      uri = hash[:channel_uri]
      type = hash[:channel_type]
      description = hash[:channel_description]
      new(uri, type, description)
    end
  end
end
