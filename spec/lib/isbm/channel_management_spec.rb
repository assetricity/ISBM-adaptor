require 'spec_helper'

describe Isbm::ChannelManagement, :external_service => true do
  HTTPI.log = false
  Savon.log = false

  Given(:uri) { "Test#{Time.now.to_i}" }
  Given(:type) { :publication }

  context "invalid arguments" do
    describe "create channel" do
      it "raises error with no URI" do
        # TODO AM Can we use Then syntax here? e.g.
        # TODO AM Then { Isbm::ChannelManagement.create_channel(nil, type).should raise_error }
        lambda { Isbm::ChannelManagement.create_channel(nil, type) }.should raise_error
      end

      it "raises error with no type" do
        lambda { Isbm::ChannelManagement.create_channel(uri, nil) }.should raise_error
      end

      it "raises error with incorrect type" do
        lambda { Isbm::ChannelManagement.create_channel(uri, :invalid_channel_type) }.should raise_error
      end
    end

    describe "get channel" do
      it "raises error with no URI" do
        lambda { Isbm::ChannelManagement.get_channel(nil) }.should raise_error
      end
    end

    describe "delete channel" do
      it "raises error with no URI" do
        lambda { Isbm::ChannelManagement.delete_channel(nil) }.should raise_error
      end
    end
  end

  context "valid arguments" do
    before(:all) { Isbm::ChannelManagement.create_channel(uri, type); puts "this works!" }

    describe "get channel" do
      it "returns a channel hash" do
        Given(:channel) { Isbm::ChannelManagement.get_channel(uri) }
        Then { channel.should_not be_nil }
        Then { channel[:channel_uri].should_not be_nil }
        Then { channel[:channel_uri].is_a?(String).should be_true }
        Then { channel[:channel_type].should_not be_nil }
        Then { channel[:channel_type].is_a?(String).should be_true }
      end
    end

    describe "get channels" do
      it "returns an array of channel hashes" do
        Given(:channels) { Isbm::ChannelManagement.get_channels }
        Then { channels.should_not be_nil }
        Then { channels.is_a?(Array).should be_true }
        Then { channels.first[:channel_uri].should_not be_nil }
        Then { channels.first[:channel_uri].is_a?(String).should be_true }
        Then { channels.first[:channel_type].should_not be_nil }
        Then { channels.first[:channel_type].is_a?(String).should be_true }
      end
    end

    after(:all) { Isbm::ChannelManagement.delete_channel(uri) }
  end
end
