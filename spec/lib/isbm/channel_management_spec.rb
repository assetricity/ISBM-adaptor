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
    end

    it "raises error when no channel_id is given" do
      lambda{ Isbm::ChannelManagement.create_channel }.should raise_error
    end

    context "with a new Channel" do
      Scenario "create channel responds with success" do
        Then { @response[:channel_id].should_not be_nil }
      end

      context "with a topic" do
        Given ( :topic_name ) { "Spec Test Topic" }
        Given ( :description ) { "A Test Topic" }
        before(:all) do
          @response = Isbm::ChannelManagement.create_topic(:channel_id => @id, :topic_name => topic_name, :topic_description => description )
        end
        # TODO add Xpath definition test
        # Then { @topic.xpath_definition.should == xpath_def }


        Scenario "topics can be gathered for that channel" do
          When { @topics = Isbm::ChannelManagement.get_all_topics(@id).map{ |topic| topic[:topic_name] } }
          Then { @topics.should include(topic_name) }
        end
      end
    end

    Scenario "channel can be deleted" do
      When { @delete_channel_response = Isbm::ChannelManagement.delete_channel :channel_id => @id }
      Then { @delete_channel_response[:fault].should be_nil }
    end
  end
end
