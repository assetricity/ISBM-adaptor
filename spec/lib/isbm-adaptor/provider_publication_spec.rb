require 'spec_helper'

describe IsbmAdaptor::ProviderPublication, :vcr do
  let(:client) { IsbmAdaptor::ProviderPublication.new(ENDPOINTS['provider_publication'], OPTIONS) }

  context 'with invalid arguments' do
    describe '#open_session' do
      it 'raises error with no URI' do
        expect { client.open_session(nil) }.to raise_error ArgumentError
      end
    end

    describe '#post_publication' do
      let(:session_id) { 'session id' }
      let(:content) { '<test/>' }
      let(:invalid_content) { '<test>' }
      let(:topics) { ['topic'] }

      it 'raises error with no session id' do
        expect { client.post_publication(nil, content, topics) }.to raise_error ArgumentError
      end

      it 'raises error with no content' do
        expect { client.post_publication(session_id, nil, topics) }.to raise_error ArgumentError
      end

      it 'raises error with invalid content' do
        expect { client.post_publication(session_id, invalid_content, topics) }.to raise_error ArgumentError
      end

      it 'raises error with no topics' do
        expect { client.post_publication(session_id, content, nil) }.to raise_error ArgumentError
      end
    end

    describe '#expire_publication' do
      let(:session_id) { 'session id' }
      let(:message_id) { 'message id' }

      it 'raises error with no session id' do
        expect { client.expire_publication(nil, message_id) }.to raise_error ArgumentError
      end

      it 'raises error with no message id' do
        expect { client.expire_publication(session_id, nil) }.to raise_error ArgumentError
      end
    end

    describe 'close publication session' do
      it 'raises error with no session id' do
        expect { client.close_session(nil) }.to raise_error ArgumentError
      end
    end
  end

  context 'with valid arguments' do
    let(:uri) { 'Test#{Time.now.to_i}' }
    let(:type) { :publication }
    let(:channel_management_client) { IsbmAdaptor::ChannelManagement.new(ENDPOINTS['channel_management'], OPTIONS) }
    before { channel_management_client.create_channel(uri, type) }

    let(:session_id) { client.open_session(uri) }

    describe '#open_session' do
      it 'returns a session id' do
        session_id.should_not be_nil
      end
    end

    describe '#post_publication' do
      let(:content) { '<test/>' }
      let(:topic_string) { 'topic' }
      let(:topic_array) { [topic_string] }

      let(:message_id) { client.post_publication(session_id, content, topic_array) }

      it 'returns a message id' do
        message_id.should_not be_nil
      end

      it 'raises no error with single topic string' do
        expect { client.post_publication(session_id, content, topic_string)}.not_to raise_error
      end

      let(:expiry) { IsbmAdaptor::Duration.new(hours: 1) }
      it 'raises no error with expiry' do
        expect { client.post_publication(session_id, content, topic_string, expiry) }.not_to raise_error
      end
    end

    after do
      client.close_session(session_id)
      channel_management_client.delete_channel(uri)
    end
  end
end
