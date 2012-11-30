module IsbmAdaptor
  class Channel
    TYPES = { :publication => "Publication", :request => "Request", :response => "Response" }

    attr_accessor :uri, :type, :description

    def initialize(uri, type, description)
      @uri = uri.to_s
      @type = TYPES.index(type)
      @description = description.to_s unless description.nil?
    end

    def self.from_hash(hash)
      uri = hash[:channel_uri]
      type = hash[:channel_type]
      description = hash[:channel_description]
      new(uri, type, description)
    end
  end
end