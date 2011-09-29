require 'spec_helper'

describe Isbm::ChannelManagement, :external_service => true do
  HTTPI.log = false
  Savon.log = false
  describe "Basic Channel Services" do
    When { @initial_channels = Isbm::ChannelManagement.get_all_channels }

    describe "new Channel" do
      Given(:chtype) {"1"}
      Given(:channel_name) {"Test#{Time.now.to_i}"}
      Given(:id) { @response[:channel_id] }
      Given(:info) { Isbm::ChannelManagement.get_info id }
      When { @response = Isbm::ChannelManagement.create_channel(:channel_name => channel_name, :channel_type => chtype) }

      Scenario "create channel responds with success" do
        Then { Isbm::ChannelManagement.was_successful @response}
      end

      Scenario "channel is in list of all channels" do
        Then { Isbm::ChannelManagement.get_all_channels.include?(id) }
      end

      Scenario "channel info can be collected" do
        Given ( :info ) { Isbm::ChannelManagement.get_channel_info id }
        Then { info[:channel_name].should == channel_name }
        Then { info[:channel_type].should == chtype }
        Then { info[:topic].should == nil }
      end

      describe "with a topic" do
        Given (:topic_name) {"Spec Test Topic"}
        When { @topic = Isbm::ChannelManagement.create_topic(:channel_id => id, :topic_name => topic_name) }
        When { @channel_info = Isbm::ChannelManagement.get_channel_info id }

        Scenario "returns that topic in the channel info" do
          Then { @channel_info[:topic].should include(topic_name) }
        end

        Scenario "topics can be gathered for that channel" do
          Then { Isbm::ChannelManagement.get_topics(id).should include(topic_name) }
        end
      end

      Scenario "channel can be deleted" do
        When { @delete_channel_response = Isbm::ChannelManagement.delete_channel id }
        Then { Isbm::ChannelManagement.was_successful @delete_channel_response }
      end

      after(:each) do
        Isbm::ChannelManagement.delete_channel id
      end
    end
    Scenario "this test leaves nothing behind" do
      Then { @initial_channels.length.should == Isbm::ChannelManagement.get_all_channels.length }
    end
  end
end

