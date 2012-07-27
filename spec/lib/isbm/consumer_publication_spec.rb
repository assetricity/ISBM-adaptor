require 'spec_helper'

describe Isbm::ProviderPublication, :external_service => true do
  HTTPI.log = false
  Savon.log = false

  context "invalid arguments" do
    describe "open subscription session" do
      Given(:uri) { "Test#{Time.now.to_i}" }
      Given(:topics) { ["topics"] }

      it "raises error with no URI" do
        lambda { Isbm::ConsumerPublication.open_session(nil, topics) }.should raise_error
      end

      it "raises error with no topics" do
        lambda { Isbm::ConsumerPublication.open_session(uri, nil) }.should raise_error
      end
    end

    describe "read publication" do
      it "raises error with no session id" do
        lambda { Isbm::ConsumerPublication.read_publication(nil) }.should raise_error
      end
    end

    describe "close subscription session" do
      it "raises error with no session id" do
        lambda { Isbm::ConsumerPublication.close_session(nil) }.should raise_error
      end
    end
  end

  context "valid arguments" do
    Given(:uri) { "Test#{Time.now.to_i}" }
    Given(:type) { :publication }
    Given(:topics) { ["topic"] }
    Given(:content) { "<test/>" }

    before(:all) { Isbm::ChannelManagement.create_channel(uri, type) }

    When(:provider_session_id) { Isbm::ProviderPublication.open_session(uri) }
    When(:consumer_session_id) { Isbm::ConsumerPublication.open_session(uri, topics) }

    describe "open subscription session" do
      it "returns a string" do
        Then { consumer_session_id.is_a?(String).should be_true }
      end
    end

    describe "read publication" do
      When { Isbm::ProviderPublication.post_publication(provider_session_id, content, topics) }
      When(:message) { Isbm::ConsumerPublication.read_publication(consumer_session_id, nil) }

      it "returns a message" do
        Then { message[:message_id].should_not be_nil }
        Then { message[:message_id].is_a?(String).should be_true }
        Then { message[:message_content].should_not be_nil }
        # TODO AM How to check it's an XML payload?
        Then { Nokogiri::XML.parse(message[:message_content].to_xml).should_not raise_error }
        Then { message[:topic].should_not be_nil }
      end
    end

    after(:all) do
      Isbm::ProviderPublication.close_session(provider_session_id)
      Isbm::ChannelManagement.delete_channel(uri)
    end
  end
end
