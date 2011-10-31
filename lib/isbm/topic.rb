module Isbm
  class Topic
    include Isbm

    attr_accessor :name, :channel_id, :description, :xpath_definition

    def initialize(attrs)
      load_data attrs
    end

    def reload
      new_info = Isbm::ChannelManagement.get_topic_info channel_id, name
      load_data new_info
    end

    private
    def load_data(attrs)
      @name = attrs[:topic]
      @channel_id = attrs[:channel_id]
      @description = attrs[:description]
      @xpath_definition = attrs[:xpath_definition]
    end
  end
end
