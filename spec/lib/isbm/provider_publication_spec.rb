require 'spec_helper'

describe Isbm::ProviderPublication, :external_service => true do
  context "with invalid arguments" do
    describe "#open_session" do
      it "raises error with no URI" do
        lambda { Isbm::ProviderPublication.open_session(nil) }.should raise_error
      end
    end

    describe "#post_publication" do
      let(:session_id) { "session id" }
      let(:content) { "<test/>" }
      let(:topics) { ["topic"] }

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

    describe "#expire_publication" do
      let(:message_id) { "message id" }

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

  context "with valid arguments" do
    let(:uri) { "Test#{Time.now.to_i}" }
    let(:type) { :publication }

    before(:all) { Isbm::ChannelManagement.create_channel(uri, type) }

    let(:session_id) { Isbm::ProviderPublication.open_session(uri) }

    describe "#open_session" do
      it "returns a session id" do
        session_id.should_not be_nil
      end
    end

    describe "#post_publication" do
      let(:content) { "<test/>" }
      let(:topics) { ["topic"] }

      let(:message_id) { Isbm::ProviderPublication.post_publication(session_id, content, topics) }

      it "returns a message id" do
        message_id.should_not be_nil
      end
    end

    after(:all) do
      Isbm::ProviderPublication.close_session(session_id)
      Isbm::ChannelManagement.delete_channel(uri)
    end
  end
end
