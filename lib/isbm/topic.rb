module Isbm
  class Topic
    include Isbm

    attr_accessor :name, :channel_id, :description, :xpath_definition

    def initialize(attrs)
      load_data attrs
    end

    def reload
      new_info = gather_info
      load_data new_info
    end

    def exists?
      info = gather_info
      Isbm.was_successful info
    end

    private
    def load_data(attrs)
      @name = attrs[:topic]
      @channel_id = attrs[:channel_id]
      @description = attrs[:description]
      @xpath_definition = attrs[:xpath_definition]
    end

    def gather_info
      Isbm::ChannelManagement.get_topic_info :channel_id => channel_id, :topic_name => name
    end
  end
end
