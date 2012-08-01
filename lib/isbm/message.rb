module Isbm
  class Message

    attr_accessor :id, :content, :topics

    def initialize(id, content, topics)
      @id = id.to_s
      @content = content
      @topics = topics
    end
  end
end