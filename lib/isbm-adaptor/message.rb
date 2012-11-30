module IsbmAdaptor
  class Message

    attr_accessor :id, :content, :topics

    def initialize(id, content, topics)
      @id = id.to_s
      @content = content
      if (topics.is_a?(Array))
        @topics.each { |t| t.to_s }
      else
        @topics = [topics.to_s]
      end
    end
  end
end