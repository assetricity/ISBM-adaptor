module IsbmAdaptor
  class Message
    # @return [String] the id of the message
    attr_accessor :id

    # @return [String] the XML content of the message
    attr_accessor :content

    # @return [Array<String>] topics associated with the message
    attr_accessor :topics

    # Creates a new ISBM Message container.
    #
    # @param id [String] message id
    # @param content [String] XML content
    # @param topics [Array<String>, String] collection of topics or single topic
    def initialize(id, content, topics)
      @id = id
      @content = content
      @topics = [topics].flatten
    end
  end
end
