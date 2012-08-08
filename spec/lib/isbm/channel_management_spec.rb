require 'spec_helper'

describe Isbm::ChannelManagement do
  let(:uri) { "Test" }
  let(:type) { :publication }
  let(:description) { "description" }

  context "when invalid arguments" do
    describe "#create_channel" do
      it "raises error with no URI" do
        expect { Isbm::ChannelManagement.create_channel(nil, type) }.to raise_error
      end

      it "raises error with no type" do
        expect { Isbm::ChannelManagement.create_channel(uri, nil) }.to raise_error
      end

      it "raises error with incorrect type" do
        expect { Isbm::ChannelManagement.create_channel(uri, :invalid_channel_type) }.to raise_error
      end
    end

    describe "#get_channel" do
      it "raises error with no URI" do
        expect { Isbm::ChannelManagement.get_channel(nil) }.to raise_error
      end
    end

    describe "#delete_channel" do
      it "raises error with no URI" do
        expect { Isbm::ChannelManagement.delete_channel(nil) }.to raise_error
      end
    end
  end

  context "when valid arguments" do
    before do
      Isbm::ChannelManagement.create_channel(uri, type, description)
    end

    describe "#get_channel" do
      let(:channel) { Isbm::ChannelManagement.get_channel(uri) }
      it "returns a valid channel", :vcr do
        channel.uri.should eq uri
        channel.type.should eq type
        channel.description.should eq description
      end
    end

    describe "#get_channels" do
      let(:channels) { Isbm::ChannelManagement.get_channels }
      it "returns an array of valid channels", :vcr do
        (channel = channels.find { |channel| channel.uri == uri }).should_not be_nil
        channel.type.should eq type
        channel.description.should eq description
      end
    end

    after do
      Isbm::ChannelManagement.delete_channel(uri)
    end
  end
end
