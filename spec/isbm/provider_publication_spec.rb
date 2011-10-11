require 'spec_helper'

describe Isbm::ProviderPublication, :external_service => true do
  HTTPI.log = false
  Savon.log = false

  context "when some channel exists" do
    Given(:channel_name) {"Test#{Time.now.to_i}"}
    before :all do
      @create_channel_response = Isbm::ChannelManagement.create_channel(:channel_name => channel_name, :channel_type => 1)
      @channel = @create_channel_response[:channel_id]
    end

    it "created successfully" do
      Isbm::ChannelManagement.was_successful @create_channel_response
    end

    describe "open publication" do
      before do
        @open_pub_response = Isbm::ProviderPublication.open_publication :channel_id => @channel
        @session_id = @open_pub_response[:channel_session_id]
      end

      it "is successful in opening a publication channel" do
        Isbm::ProviderPublication.was_successful( @open_pub_response ).should be_true
      end

      describe "post publication" do
        let(:topic_name) { "test_topic" }
        let(:message) { "Some Message" }
        before do
          @create_topic_response = Isbm::ChannelManagement.create_topic(:channel_id => @channel, :topic => topic_name)
          @post_publication_response = Isbm::ProviderPublication.post_publication( :channel_session_id => @session_id, :topic => topic_name, :publication_message => message)
        end

        it "posted message successfully" do
          Isbm::ProviderPublication.was_successful(@post_publication_response)
        end
      end

      describe "close publication" do
        before do
          @close_pub_response = Isbm::ProviderPublication.close_publication :channel_session_id => @session_id
        end

        it "is successful in closing a publication" do
          Isbm::ProviderPublication.was_successful( @close_pub_response ).should be_true
        end
      end
    end

    after :all do
      Isbm::ChannelManagement.delete_channel(@channel)
    end
  end
end
