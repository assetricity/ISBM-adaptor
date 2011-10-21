require 'spec_helper'

describe Isbm::Channel do
  context "with a single channel and no topics" do
    before(:all) do
      @create_channel_response = Isbm::ChannelManagement.create_channel :channel_name => "Test", :channel_type => "1"
      @channel_id = @create_channel_response[:channel_id]
    end
    after(:all) do
      Isbm::ChannelManagement.delete_channel @channel_id
    end
  end
end
