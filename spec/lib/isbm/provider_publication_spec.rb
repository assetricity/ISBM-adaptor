require 'spec_helper'

describe Isbm::ProviderPublication, :external_service => true do
  HTTPI.log = false
  Savon.log = false

  context "when some channel exists" do
    Given(:channel_name) {"Test#{Time.now.to_i}"}
    before :all do
      @create_channel_response = Isbm::ChannelManagement.create_channel(:channel_name => channel_name, :channel_type => "Publication")
      @channel_id = @create_channel_response[:channel_id]
    end

    describe "open publication" do
      before(:all) do
        @open_pub_response = Isbm::ProviderPublication.open_publication :channel_id => @channel_id
        @session_id = @open_pub_response[:session_id]
        @session = Isbm::ChannelManagement.get_session( @session_id )
      end

      it "is successful in opening a publication channel" do
        @open_pub_response.should_not be_nil
      end

      it "has the session object" do
        @session.isbm_id.should == @session_id
        @session.type.should == "Provider"
        @session.channel.should == @channel_id
      end

      describe "post publication" do
        let(:topic_name) { "test_topic" }
        let(:message) { "<CCOMData>Some Message</CCOMData>" }

        before(:all) do
          @create_topic_response = Isbm::ChannelManagement.create_topic(:channel_id => @channel_id, :topic_name => topic_name)
          @post_publication_response = Isbm::ProviderPublication.post_publication( :session_id => @session_id, :topic_name => topic_name, :message => message)
        end

        it "raises error when no message is given" do
          lambda { Isbm::ProviderPublication.post_publication :channel_session_id => @session_id, :topic_name => topic_name }.should raise_error
        end

        it "posted message successfully" do
          @post_publication_response[:fault].should be_nil
        end
      end

      describe "close publication" do
        before do
          @close_pub_response = Isbm::ProviderPublication.close_publication :channel_session_id => @session_id
        end

        it "is successful in closing a publication" do
          @close_pub_response[:fault].should be_nil
        end
      end
    end

    after :all do
      Isbm::ChannelManagement.delete_channel(:channel_id => @channel_id)
    end
  end
end
