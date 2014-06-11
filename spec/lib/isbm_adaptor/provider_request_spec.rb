require 'spec_helper'

describe IsbmAdaptor::ProviderRequest, :vcr do
  let(:client) { IsbmAdaptor::ProviderRequest.new(ENDPOINTS['provider_request'], OPTIONS) }

  context 'with invalid arguments' do
    describe '#open_session' do
      let(:uri) { 'Test' }
      let(:topic) { 'topics' }

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

    describe '#read_request' do
      it 'raises error with no session id' do
        expect { client.read_request(nil) }.to raise_error ArgumentError
      end
    end

    describe '#remove_request' do
      it 'raises error with no session id' do
        expect { client.remove_request(nil) }.to raise_error ArgumentError
      end
    end

    describe '#post_response' do
      let(:session_id) { 'session id' }
      let(:request_message_id) { 'request message id' }
      let(:content) { '<test/>' }
      let(:invalid_content) { '<test>' }

      it 'raises error with no session id' do
        expect { client.post_response(nil, request_message_id, content) }.to raise_error ArgumentError
      end

      it 'raises error with no request message id' do
        expect { client.post_response(session_id, nil, content) }.to raise_error ArgumentError
      end

      it 'raises error with no content' do
        expect { client.post_response(session_id, request_message_id, nil) }.to raise_error ArgumentError
      end

      it 'raises error with invalid content' do
        expect { client.post_response(session_id, request_message_id, invalid_content) }.to raise_error ArgumentError
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
    let(:type) { :request }
    let(:topic) { 'topic' }
    let(:content) { File.read(File.expand_path(File.dirname(__FILE__)) + '/../../fixtures/ccom.xml') }
    let(:channel_client) { IsbmAdaptor::ChannelManagement.new(ENDPOINTS['channel_management'], OPTIONS) }
    before { channel_client.create_channel(uri, type) }

    let!(:provider_session_id) { client.open_session(uri, topic) }

    describe '#open_session' do
      it 'returns a session id' do
        provider_session_id.should_not be_nil
      end

      context 'multiple topic array' do
        let(:topic) { [topic, 'another topic'] }
        it 'returns a session id' do
          consumer_session_id.should_not be_nil
        end
      end
    end

    context 'with consumer' do
      let(:consumer_client) { IsbmAdaptor::ConsumerRequest.new(ENDPOINTS['consumer_request'], OPTIONS) }
      let(:consumer_session_id) { consumer_client.open_session(uri) }
      before { consumer_client.post_request(consumer_session_id, content, topic) }
      let(:request) { client.read_request(provider_session_id) }

      describe '#read_request' do
        it 'returns a valid request message' do
          request.id.should_not be_nil
          request.topics.first.should == topic
          request.content.root.name.should == 'CCOMData'
        end
      end

      describe '#remove_request' do
        before { client.remove_request(provider_session_id) }

        it 'removes the request from the queue' do
          request.should be_nil
        end
      end

      describe '#post_response' do
        let(:response_message_id) { client.post_response(provider_session_id, request.id, content) }

        it 'returns a response message id' do
          response_message_id.should_not be_nil
        end
      end

      after { consumer_client.close_session(consumer_session_id) }
    end

    after do
      client.close_session(provider_session_id)
      channel_client.delete_channel(uri)
    end
  end
end
