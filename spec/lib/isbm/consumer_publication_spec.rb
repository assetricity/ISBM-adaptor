require 'spec_helper'

describe Isbm::ConsumerPublication, :external_service => true do
  context "with invalid arguments" do
    describe "#open_session" do
      let(:uri) { "Test#{Time.now.to_i}" }
      let(:topics) { ["topics"] }

      it "raises error with no URI" do
        expect { Isbm::ConsumerPublication.open_session(nil, topics) }.to raise_error
      end

      it "raises error with no topics" do
        expect { Isbm::ConsumerPublication.open_session(uri, nil) }.to raise_error
      end
    end

    describe "#read_publication" do
      it "raises error with no session id" do
        expect { Isbm::ConsumerPublication.read_publication(nil, nil) }.to raise_error
      end
    end

    describe "#close_session" do
      it "raises error with no session id" do
        expect { Isbm::ConsumerPublication.close_session(nil) }.to raise_error
      end
    end
  end

  context "with valid arguments" do
    let(:uri) { "Test#{Time.now.to_i}" }
    let(:type) { :publication }
    let(:topics) { ["topic"] }
    let(:content) { '<CCOMData xmlns:xsi="http://www.w3.org/2001/XMLSchema-instance" xmlns="http://www.mimosa.org/osa-eai/v3-2-3/xml/CCOM-ML"><Entity xsi:type="Asset"><GUID>C013C740-19F5-11E1-92B7-6B8E4824019B</GUID></Entity></CCOMData>' }

    before(:all) { Isbm::ChannelManagement.create_channel(uri, type) }

    let(:provider_session_id) { Isbm::ProviderPublication.open_session(uri) }
    let(:consumer_session_id) { Isbm::ConsumerPublication.open_session(uri, topics) }

    describe "#open_session" do
      it "returns a session id" do
        consumer_session_id.should_not be_nil
      end
    end

    describe "#read_publication" do
      before(:all) { Isbm::ProviderPublication.post_publication(provider_session_id, content, topics) }
      let(:message) { Isbm::ConsumerPublication.read_publication(consumer_session_id, nil) }

      it "returns a valid message" do
        message.id.should_not be_nil
        message.topics.first.should eq topics.first
        message.content.name.should eq "CCOMData"
      end
    end

    after(:all) do
      Isbm::ProviderPublication.close_session(provider_session_id)
      Isbm::ChannelManagement.delete_channel(uri)
    end
  end
end
