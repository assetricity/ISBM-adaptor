require 'spec_helper'

describe IsbmAdaptor::ConsumerRequest, :vcr do
  let(:client) { IsbmAdaptor::ConsumerRequest.new(ENDPOINTS['consumer_request'], OPTIONS) }

  context 'with invalid arguments' do
    describe '#open_session' do
      it 'raises error with no URI' do
        expect { client.open_session(nil) }.to raise_error ArgumentError
      end
    end

    describe '#post_request' do
      let(:session_id) { 'session id' }
      let(:content) { '<test/>' }
      let(:invalid_content) { '<test>' }
      let(:topic) { 'topic' }

      it 'raises error with no session id' do
        expect { client.post_request(nil, content, topic) }.to raise_error ArgumentError
      end

      it 'raises error with no content' do
        expect { client.post_request(session_id, nil, topic) }.to raise_error ArgumentError
      end

      it 'raises error with invalid content' do
        expect { client.post_request(session_id, invalid_content, topic) }.to raise_error ArgumentError
      end

      it 'raises error with no topics' do
        expect { client.post_request(session_id, content, nil) }.to raise_error ArgumentError
      end
    end

    describe '#expire_request' do
      let(:session_id) { 'session id' }
      let(:message_id) { 'message id' }

      it 'raises error with no session id' do
        expect { client.expire_request(nil, message_id) }.to raise_error ArgumentError
      end

      it 'raises error with no message id' do
        expect { client.expire_request(session_id, nil) }.to raise_error ArgumentError
      end
    end

    describe '#read_response' do
      let(:session_id) { 'session id' }
      let(:request_message_id) { 'request message id' }

      it 'raises error with no session id' do
        expect { client.read_response(nil, request_message_id) }.to raise_error ArgumentError
      end

      it 'raises error with no request message id' do
        expect { client.read_response(session_id, nil) }.to raise_error ArgumentError
      end
    end

    describe '#remove_response' do
      let(:session_id) { 'session id' }
      let(:request_message_id) { 'request message id' }

      it 'raises error with no session id' do
        expect { client.remove_response(nil, request_message_id) }.to raise_error ArgumentError
      end

      it 'raises error with no request message id' do
        expect { client.remove_response(session_id, nil) }.to raise_error ArgumentError
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

    let(:consumer_session_id) { client.open_session(uri) }

    describe '#open_session' do
      it 'returns a session id' do
        consumer_session_id.should_not be_nil
      end
    end

    describe '#post_request' do
      let(:request_message_id) { client.post_request(consumer_session_id, content, topic) }

      it 'returns a request message id' do
        request_message_id.should_not be_nil
      end

      let(:expiry) { IsbmAdaptor::Duration.new(hours: 1) }
      it 'raises no error with expiry' do
        expect { client.post_request(consumer_session_id, content, topic, expiry) }.not_to raise_error
      end
    end

    describe '#expire_request' do
      let(:request_message_id) { client.post_request(consumer_session_id, content, topic) }

      it 'raises no error' do
        expect { client.expire_request(consumer_session_id, request_message_id) }.not_to raise_error
      end
    end

    context 'with provider' do
      let(:provider_request_client) { IsbmAdaptor::ProviderRequest.new(ENDPOINTS['provider_request'], OPTIONS) }
      let!(:provider_session_id) { provider_request_client.open_session(uri, [topic]) }
      let!(:request_message_id) { client.post_request(consumer_session_id, content, topic) }
      before { provider_request_client.post_response(provider_session_id, request_message_id, content) }
      let(:response) { client.read_response(consumer_session_id, request_message_id) }

      describe '#read_response' do
        it 'returns a valid response message' do
          response.id.should_not be_nil
          response.content.root.name.should == 'CCOMData'
        end
      end

      describe '#remove_response' do
        before { client.remove_response(consumer_session_id, request_message_id) }

        it 'removes the response from the queue' do
          response.should be_nil
        end
      end

      after { provider_request_client.close_session(provider_session_id) }
    end

    after do
      client.close_session(consumer_session_id)
      channel_client.delete_channel(uri)
    end
  end
end
