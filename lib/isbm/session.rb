module Isbm
  class Session
    attr_accessor :isbm_id, :type, :channel, :listener_uri

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
      @isbm_id = attrs[:session_id]
      @channel = attrs[:channel_id]
      @type = attrs[:application_type]
    end
  end
end
