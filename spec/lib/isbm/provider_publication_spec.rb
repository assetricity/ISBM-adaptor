require 'spec_helper'

describe Isbm::ProviderPublication, :external_service => true do
  HTTPI.log = false
  Savon.configure do |config|
    config.log = false
  end

  context "invalid arguments" do
    describe "open publication session" do
      it "raises error with no URI" do
        lambda { Isbm::ProviderPublication.open_session(nil) }.should raise_error
      end
    end

    describe "post publication" do
      Given(:session_id) { "session id" }
      Given(:content) { "<test/>" }
      Given(:topics) { ["topic"] }

      it "raises error with no session id" do
        lambda { Isbm::ProviderPublication.post_publication(nil, content, topics) }.should raise_error
      end

      it "raises error with no content" do
        lambda { Isbm::ProviderPublication.post_publication(session_id, nil, topics) }.should raise_error
      end

      it "raises error with no topics" do
        lambda { Isbm::ProviderPublication.post_publication(session_id, content, nil) }.should raise_error
      end
    end

    describe "expire publication" do
      Given(:message_id) { "message id" }

      it "raises error with no session id" do
        lambda { Isbm::ProviderPublication.expire_publication(nil, message_id) }.should raise_error
      end

      it "raises error with no message id" do
        lambda { Isbm::ProviderPublication.expire_publication(session_id, nil) }.should raise_error
      end
    end

    describe "close publication session" do
      it "raises error with no session id" do
        lambda { Isbm::ProviderPublication.close_session(nil) }.should raise_error
      end
    end
  end

  context "valid arguments" do
    Given(:uri) { "Test#{Time.now.to_i}" }
    Given(:type) { :publication }

    before(:all) { Isbm::ChannelManagement.create_channel(uri, type) }

    When(:session_id) { Isbm::ProviderPublication.open_session(uri) }

    describe "open publication session" do
      context "returns a string" do
        Then { session_id.should_not be_nil }
        Then { session_id.is_a?(String).should be_true }
      end
    end

    describe "post publication" do
      context "returns a string" do
        Given(:content) { "<test/>" }
        Given(:topics) { ["topic"] }

        When(:message_id) { Isbm::ProviderPublication.post_publication(session_id, content, topics) }

        Then { message_id.should_not be_nil }
        Then { message_id.is_a?(String).should be_true }
      end
    end

    after(:all) do
      Isbm::ProviderPublication.close_session(session_id)
      Isbm::ChannelManagement.delete_channel(uri)
    end
  end
end
