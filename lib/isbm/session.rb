module Isbm
  class Session
    attr_accessor :isbm_id, :type, :topic, :listener_uri

    def initialize(attrs)
      load_data attrs
    end

    def reload
      attrs = Isbm::ChannelManagement.get_session_info :channel_session_id => id
      load_data attrs
    end

    def exists?
      response = Isbm::ChannelManagement.get_session_info :channel_session_id => id
      Isbm.was_successful response
    end

    private
    def load_data(attrs)
      @isbm_id = attrs[:channel_session_id]
      @type = attrs[:channel_session_type]
      @topic = attrs[:topic]
      @listener_uri = attrs[:listener_uri]
    end
  end
end
