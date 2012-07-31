module Isbm
  class Message

    attr_accessor :id
    attr_accessor :content
    attr_accessor :topics

    def initialize(id, content, topics)
      @id = id.to_s
      @content = content
      @topics = topics
    end
  end
end