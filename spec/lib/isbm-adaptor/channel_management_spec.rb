require "spec_helper"

describe IsbmAdaptor::ChannelManagement do
  let(:uri) { "Test" }
  let(:type) { :publication }
  let(:description) { "description" }

  context "when invalid arguments" do
    describe "#create_channel" do
      it "raises error with no URI" do
        expect { IsbmAdaptor::ChannelManagement.create_channel(nil, type) }.to raise_error
      end

      it "raises error with no type" do
        expect { IsbmAdaptor::ChannelManagement.create_channel(uri, nil) }.to raise_error
      end

      it "raises error with incorrect type" do
        expect { IsbmAdaptor::ChannelManagement.create_channel(uri, :invalid_channel_type) }.to raise_error
      end
    end

    describe "#get_channel" do
      it "raises error with no URI" do
        expect { IsbmAdaptor::ChannelManagement.get_channel(nil) }.to raise_error
      end
    end

    describe "#delete_channel" do
      it "raises error with no URI" do
        expect { IsbmAdaptor::ChannelManagement.delete_channel(nil) }.to raise_error
      end
    end
  end

  context "when valid arguments" do
    before do
      IsbmAdaptor::ChannelManagement.create_channel(uri, type, description)
    end

    describe "#get_channel" do
      let(:channel) { IsbmAdaptor::ChannelManagement.get_channel(uri) }
      it "returns a valid channel", :vcr do
        channel.uri.should eq uri
        channel.type.should eq type
        channel.description.should eq description
      end
    end

    describe "#get_channels" do
      let(:channels) { IsbmAdaptor::ChannelManagement.get_channels }
      it "returns an array of valid channels", :vcr do
        (channel = channels.find { |channel| channel.uri == uri }).should_not be_nil
        channel.type.should eq type
        channel.description.should eq description
      end
    end

    after do
      IsbmAdaptor::ChannelManagement.delete_channel(uri)
    end
  end
end
