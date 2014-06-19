require 'spec_helper'

describe IsbmAdaptor::ConsumerPublication, :vcr do
  let(:client) { IsbmAdaptor::ConsumerPublication.new(ENDPOINTS['consumer_publication'], OPTIONS) }

  context 'with invalid arguments' do
    describe '#open_session' do
      let(:uri) { 'Test' }
      let(:topic) { 'topic' }

      it 'raises error with no URI' do
        expect { client.open_session(nil, topic) }.to raise_error ArgumentError
      end

      it 'raises error with no topics' do
        expect { client.open_session(uri, nil) }.to raise_error ArgumentError
      end

      it 'raises error when XPath namespace but no expression' do
        expect { client.open_session(uri, topic, nil, nil, {prefix: 'name'}) }.to raise_error ArgumentError
      end
    end

    describe '#read_publication' do
      it 'raises error with no session id' do
        expect { client.read_publication(nil) }.to raise_error ArgumentError
      end
    end

    describe '#close_session' do
      it 'raises error with no session id' do
        expect { client.close_session(nil) }.to raise_error ArgumentError
      end
    end
  end

  context 'with valid arguments' do
    let(:uri) { 'Test' }
    let(:type) { :publication }
    let(:topic) { 'topic' }
    let(:content) { File.read(File.expand_path(File.dirname(__FILE__)) + '/../../fixtures/ccom.xml') }
    let(:channel_client) { IsbmAdaptor::ChannelManagement.new(ENDPOINTS['channel_management'], OPTIONS) }
    before { channel_client.create_channel(uri, type) }

    let!(:consumer_session_id) { client.open_session(uri, topic) }

    describe '#open_session' do
      it 'returns a session id' do
        consumer_session_id.should_not be_nil
      end

      context 'multiple topic array' do
        let(:topic) { ['topic', 'another topic'] }
        it 'returns a session id' do
          consumer_session_id.should_not be_nil
        end
      end
    end

    context 'with provider' do
      let(:provider_client) { IsbmAdaptor::ProviderPublication.new(ENDPOINTS['provider_publication'], OPTIONS) }
      let(:provider_session_id) { provider_client.open_session(uri) }

      describe '#read_publication' do
        before { provider_client.post_publication(provider_session_id, content, topic) }

        let(:message) { client.read_publication(consumer_session_id) }

        it 'returns a valid message' do
          message.id.should_not be_nil
          message.topics.first.should == topic
          message.content.root.name.should == 'CCOMData'
        end

        # For IsbmAdaptor::Client#extract_message
        it 'copies namespaces to content root' do
          doc = Nokogiri::XML(message.content.to_xml)
          doc.namespaces.values.should include 'http://www.w3.org/2001/XMLSchema-instance'
          doc.namespaces.values.should include 'http://www.mimosa.org/osa-eai/v3-2-3/xml/CCOM-ML'
        end

        describe '#remove_publication' do
          before { client.remove_publication(consumer_session_id) }
          let(:message2) { client.read_publication(consumer_session_id) }

          it 'returns nil when there are no more messages' do
            message2.should be_nil
          end
        end
      end

      after { provider_client.close_session(provider_session_id) }
    end

    after do
      client.close_session(consumer_session_id)
      channel_client.delete_channel(uri)
    end
  end
end
