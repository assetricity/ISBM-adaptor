require 'spec_helper'

describe Isbm::ProviderPublication, :external_service => true do
  HTTPI.log = false
  Savon.log = false

  context "when some channel exists" do
    before :all do
      response = Isbm::ChannelManagement.create_channel(:channel_name => "Test", :channel_type => 1)
      @channel = response[:channel_id]
    end

    describe "open publications" do
      before do
        @open_pub_response = Isbm::ProviderPublication.open_publication :channel_id => @channel
      end

      it "is successful in opening a publication channel" do
        Isbm::ProviderPublication.was_successful( @open_pub_response ).should be_true
      end
    end

    after :all do
      Isbm::ChannelManagement.delete_channel(@channel)
    end
  end
end
