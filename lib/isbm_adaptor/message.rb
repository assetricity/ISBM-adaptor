module IsbmAdaptor
  class Message
    attr_accessor :id, :content, :topics

    # Creates a new ISBM Message container.
    #
    # @param id [String] message id
    # @param content [String] XML content
    # @param topics [Array<String>] collection of topics
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