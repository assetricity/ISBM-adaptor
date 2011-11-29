require 'spec_helper'

describe Isbm::ProviderPublication, :external_service => true do
  HTTPI.log = false
  Savon.log = false

  context "when some channel with a topic exists" do
    Given ( :topic_name1 ) { "Topic1" }
    Given ( :topic_name2 ) { "Topic2" }
    Given ( :channel_name ) { "Test#{Time.now.to_i}" }

    before :all do
      @create_channel_response = Isbm::ChannelManagement.create_channel(:channel_name => channel_name, :channel_type => "Publication")
      @channel_id = @create_channel_response[:channel_id]
      @create_topic_response = Isbm::ChannelManagement.create_topic(:channel_id => @channel_id, :topic_name => topic_name1)
      @create_topic_response = Isbm::ChannelManagement.create_topic(:channel_id => @channel_id, :topic_name => topic_name2)
      @open_pub_response = Isbm::ProviderPublication.open_publication :channel_id => @channel_id
      @pub_session_id = @open_pub_response[:session_id]
    end

    describe "open subscription session" do
      before :all do
        @create_session_response = Isbm::ConsumerPublication.open_subscription( :channel_id => @channel_id, :topic_name => [ topic_name1, topic_name2 ] )
        @session_id = @create_session_response[:session_id]
      end

      it "was successful" do
        @session_id.should_not be_nil
      end

      describe "read publication" do
        Given ( :message ) { '<CCOMData><Entity xsi:type="Asset"><GUID>C013C740-19F5-11E1-92B7-6B8E4824019B</GUID></Entity></CCOMData>' }

        before :all do
          @post_publication_response = Isbm::ProviderPublication.post_publication( :session_id => @pub_session_id, :topic_name => topic_name1, :message => message)
          sleep(10)
          @read_response = Isbm::ConsumerPublication.read_publication( :session_id => @session_id )
        end

        it "was successful" do
          @read_response[:fault].should be_nil
        end

        it "received message" do
          @read_response.should_not be_nil
          doc = Nokogiri::XML.parse @read_response.to_xml
          message = doc.xpath("//CCOMData").first.to_s
          message.should =~ /C013C740-19F5-11E1-92B7-6B8E4824019B/
        end

        describe "remove publication" do
          before :all do
            @remove_publication_response = Isbm::ConsumerPublication.remove_publication( :session_id => @session_id )
          end

          it "was successful" do
            @remove_publication_response[:fault].should be_nil
          end
        end
      end

      describe "close subscription session" do
        before :all do
          @close_session_response = Isbm::ConsumerPublication.close_subscription( :session_id => @session_id )
        end

        it "was successful" do
          @close_session_response[:fault].should be_nil
        end
      end
    end

    after :all do
      Isbm::ChannelManagement.delete_channel(:channel_id => @channel_id)
    end
  end
end
