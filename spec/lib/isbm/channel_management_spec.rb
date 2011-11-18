require 'spec_helper'

describe Isbm::ChannelManagement, :external_service => true do
  HTTPI.log = false
  Savon.log = false

  describe "Basic Channel Services" do
    Given(:chtype) {"Publication"}
    Given(:channel_name) {"Test#{Time.now.to_i}"}

    before(:all) do 
      @response = Isbm::ChannelManagement.create_channel(:channel_name => channel_name, :channel_type => chtype.to_s)
      @id = @response[:channel_id]
      @channel = Isbm::ChannelManagement.get_channel(channel_name, chtype)
    end

    it "raises error when no channel_id is given" do
      lambda{ Isbm::ChannelManagement.create_channel }.should raise_error
    end

    context "with a new Channel" do
      Scenario "create channel responds with success" do
        Then { @response[:channel_id].should_not be_nil }
      end

      Scenario "channel is active in the isbm" do
        Then { @channel.is_active.should be_true }
      end

      Scenario "channel info can be collected" do
        Then { @channel.name.should == channel_name }
        Then { @channel.type.should == chtype }
        Then { @channel.topic_names.should == nil }
      end

      context "without a topic" do
        Given ( :topic ) { Isbm::Topic.new(:channel_id => @id, :topic => "jungle juice") }
        Then { topic.exists?.should be_false }
      end

      context "with a topic" do
        Given ( :topic_name ) { "Spec Test Topic" }
        Given ( :description ) { "A Test Topic" }
        before(:all) do
          @response = Isbm::ChannelManagement.create_topic(:channel_id => @id, :topic_name => topic_name, :topic_description => description )
          @topic = Isbm::ChannelManagement.get_topic( @id, topic_name )
        end
        Then { @topic.name.should == topic_name }
        Then { @topic.channel_id.should == @id }
        Then { @topic.description.should == description }
        Then { @topic.exists?.should be_true }
        # TODO add Xpath definition test
        # Then { @topic.xpath_definition.should == xpath_def }

        context "before channel is relaoded" do
          Then { @channel.topic_names.should be_nil }
        end

        context "after reloading the channel object" do
          When { @channel.reload }

          #TODO test with multiple topics
          Scenario "returns that topic in the channel info" do
            Then { @channel.topic_names.should include(topic_name) }
          end
        end

        Scenario "topics can be gathered for that channel" do
          Then { Isbm::ChannelManagement.get_topics(@channel.name, @channel.type).should include(topic_name) }
        end
      end
    end

    Scenario "channel can be deleted" do
      When { @delete_channel_response = Isbm::ChannelManagement.delete_channel :channel_id => @id }
      Then { @delete_channel_response[:fault].should be_nil }
    end
  end
end
