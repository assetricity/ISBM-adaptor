require 'spec_helper'

describe Isbm::ChannelManagement, :external_service => true do
  let(:uri) { "Test#{Time.now.to_i}" }
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
    before(:all) { Isbm::ChannelManagement.create_channel(uri, type, description) }

    describe "#get_channel" do
      let(:channel) { Isbm::ChannelManagement.get_channel(uri) }
      it "returns a valid channel" do
        channel.uri.should eq uri
        channel.type.should eq type
        channel.description.should eq description
      end
    end

    describe "#get_channels" do
      let(:channels) { Isbm::ChannelManagement.get_channels }
      it "returns an array of valid channels" do
        channels.first.uri.should eq uri
        channels.first.type.should eq type
        channels.first.description.should eq description
      end
    end

    after(:all) { Isbm::ChannelManagement.delete_channel(uri) }
  end
end
