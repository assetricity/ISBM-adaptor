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
      topics = gather_topics
      topics.each{ |topic| return true if topic && topic[:topic_name] == self.name }
      false
    end

    private
    def load_data(attrs)
      @name = attrs[:topic_name]
      @channel_id = attrs[:channel_id]
      @description = attrs[:topic_description]
      @xpath_definition = attrs[:x_path_expression]
    end

    def gather_topics
      Isbm::ChannelManagement.get_all_topics channel_id
    end
  end
end
