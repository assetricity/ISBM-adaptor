require 'spec_helper'

describe Isbm::ChannelManagement, :external_service => true do
  HTTPI.log = false
  Savon.log = false

  describe "Basic Channel Services" do
    Given(:chtype) {1}
    Given(:channel_name) {"Test#{Time.now.to_i}"}

    before(:all) do 
      @response = Isbm::ChannelManagement.create_channel(:channel_name => channel_name, :channel_type => chtype.to_s)
      @id = @response[:channel_id]
      @channel = Isbm::ChannelManagement.get_channel @id
    end

    context "with a new Channel" do
      Scenario "create channel responds with success" do
        Then { Isbm.was_successful( @response ).should be_true}
      end

      Scenario "channel is in list of all channels" do
        Then { Isbm::ChannelManagement.get_all_channels.include?(@id) }
      end

      Scenario "channel is active in the isbm" do
        Then { @channel.is_active.should be_true }
      end

      Scenario "channel info can be collected" do
        Then { @channel.name.should == channel_name }
        Then { @channel.type.should == Isbm::Channel.channel_types[chtype] }
        Then { @channel.topic_names.should == nil }
      end

      context "without a topic" do
        Given ( :topic ) { Isbm::Topic.new(:id => "someid") }
        Then { session.exists?.should be_false }
      end

      context "with a topic" do
        Given ( :topic_name ) {"Spec Test Topic"}
        Given ( :description ) { "A Test Topic" }
        Given ( :xpath_def ) { "/Test" }
        When do
          @response = Isbm::ChannelManagement.create_topic(:channel_id => @id, :topic => topic_name, :description => description )
          @topic = Isbm::ChannelManagement.get_topic( @id, topic_name)
        end
        Then { @topic.exists?.should be_true }
        Then { Isbm.was_successful @response }
        Then { @topic.name.should == topic_name }
        Then { @topic.channel_id.should == @id }
        Then { @topic.description.should == description }
        # TODO add Xpath definition test
        # Then { @topic.xpath_definition.should == xpath_def }

        context "before channel is relaoded" do
          Then { @channel.topic_names.should be_nil }
        end

        context "after reloading the channel object" do
          When { @channel.reload }

          Scenario "returns that topic in the channel info" do
            Then { @channel.topic_names.should include(topic_name) }
          end
        end

        Scenario "topics can be gathered for that channel" do
          Then { Isbm::ChannelManagement.get_topics(@id).should include(topic_name) }
        end
      end
    end

    Scenario "channel can be deleted" do
      When { @delete_channel_response = Isbm::ChannelManagement.delete_channel :channel_id => @id }
      Then { Isbm.was_successful( @delete_channel_response ).should be_true }
    end
  end
end
