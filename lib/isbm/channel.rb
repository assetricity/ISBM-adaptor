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
      channels = Isbm::ChannelManagement.get_all_channels
      channels.each{ |channel| return true if channel && channel[:channel_id] == self.isbm_id }
      false
    end

    def reload
      new_info = Isbm::ChannelManagement.get_channel_info( :channel_name => name, :channel_type => type )
      load_data new_info
    end

    private
    def load_data(attrs)
      @isbm_id = attrs[:channel_id]
      @name = attrs[:channel_name]
      @type = attrs[:channel_type]
      @topic_names = attrs[:topic_name]
    end
  end
end
