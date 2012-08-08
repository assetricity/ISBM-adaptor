require 'spec_helper'

describe Isbm::ConsumerPublication do
  context "with invalid arguments" do
    describe "#open_session", :vcr do
      let(:uri) { "Test" }
      let(:topics) { ["topics"] }

      it "raises error with no URI" do
        expect { Isbm::ConsumerPublication.open_session(nil, topics) }.to raise_error
      end

      it "raises error with no topics" do
        expect { Isbm::ConsumerPublication.open_session(uri, nil) }.to raise_error
      end
    end

    describe "#read_publication", :vcr do
      it "raises error with no session id" do
        expect { Isbm::ConsumerPublication.read_publication(nil, nil) }.to raise_error
      end
    end

    describe "#close_session", :vcr do
      it "raises error with no session id" do
        expect { Isbm::ConsumerPublication.close_session(nil) }.to raise_error
      end
    end
  end

  context "with valid arguments" do
    let(:uri) { "Test" }
    let(:type) { :publication }
    let(:topics) { ["topic"] }
    let(:content) { '<CCOMData xmlns:xsi="http://www.w3.org/2001/XMLSchema-instance" xmlns="http://www.mimosa.org/osa-eai/v3-2-3/xml/CCOM-ML"><Entity xsi:type="Asset"><GUID>C013C740-19F5-11E1-92B7-6B8E4824019B</GUID></Entity></CCOMData>' }

    before do
      Isbm::ChannelManagement.create_channel(uri, type)
    end

    let(:provider_session_id) { Isbm::ProviderPublication.open_session(uri) }
    let(:consumer_session_id) { Isbm::ConsumerPublication.open_session(uri, topics) }

    describe "#open_session", :vcr do
      it "returns a session id" do
        consumer_session_id.should_not be_nil
      end
    end

    describe "#read_publication", :vcr do
      before do
        Isbm::ProviderPublication.post_publication(provider_session_id, content, topics)
      end

      let(:message) { Isbm::ConsumerPublication.read_publication(consumer_session_id, nil) }

      it "returns a valid message" do
        message.id.should_not be_nil
        message.topics.first.should eq topics.first
        message.content.name.should eq "CCOMData"
      end

      let(:message2) { Isbm::ConsumerPublication.read_publication(consumer_session_id, message.id) }

      it "returns nil when there are no more messages" do
        message2.should be_nil
      end
    end

    after do
      Isbm::ProviderPublication.close_session(provider_session_id)
      Isbm::ChannelManagement.delete_channel(uri)
    end
  end
end
