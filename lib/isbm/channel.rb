module Isbm
  class Channel
    include Isbm

    attr_reader :name, :topic_names, :type, :isbm_id

    def self.channel_types
      [nil, "Publication", "Request", "Response"]
    end

    def initialize(attrs)
      load_data attrs
    end

    def is_active
      Isbm::ChannelManagement.get_all_channels.include?(self.isbm_id)
    end

    def reload
      new_info = Isbm::ChannelManagement.get_channel_info :channel_id => isbm_id
      load_data new_info
    end

    private
    def load_data(attrs) 
      @isbm_id = attrs[:channel_id]
      @name = attrs[:channel_name]
      @type = Isbm::Channel.channel_types[attrs[:channel_type].to_i]
      @topic_names = attrs[:topic]
    end
  end
end
