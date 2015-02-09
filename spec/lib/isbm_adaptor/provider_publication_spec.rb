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
      let(:topic) { 'topic' }

      it 'raises error with no session id' do
        expect { client.post_publication(nil, content, topic) }.to raise_error ArgumentError
      end

      it 'raises error with no content' do
        expect { client.post_publication(session_id, nil, topic) }.to raise_error ArgumentError
      end

      it 'raises error with invalid content' do
        expect { client.post_publication(session_id, invalid_content, topic) }.to raise_error ArgumentError
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
    let(:uri) { 'Test' }
    let(:type) { :publication }
    let(:channel_client) { IsbmAdaptor::ChannelManagement.new(ENDPOINTS['channel_management'], OPTIONS) }
    before { channel_client.create_channel(uri, type) }

    let(:session_id) { client.open_session(uri) }

    describe '#open_session' do
      it 'returns a session id' do
        expect(session_id).not_to be_nil
      end
    end

    describe 'posting' do
      let(:content) { File.read(File.expand_path(File.dirname(__FILE__)) + '/../../fixtures/ccom.xml') }
      let(:topic) { 'topic' }
      let(:message_id) { client.post_publication(session_id, content, topic) }

      describe '#post_publication' do
        it 'returns a message id' do
          expect(message_id).not_to be_nil
        end

        it 'can use a single topic string' do
          expect { client.post_publication(session_id, content, topic) }.not_to raise_error
        end

        it 'can use a multiple topic array' do
          expect { client.post_publication(session_id, content, [topic]) }.not_to raise_error
        end

        let(:expiry) { IsbmAdaptor::Duration.new(hours: 1) }
        it 'raises no error with expiry' do
          expect { client.post_publication(session_id, content, topic, expiry) }.not_to raise_error
        end
      end

      describe '#expire_publication' do
        it 'raises no error' do
          expect { client.expire_publication(session_id, message_id) }.not_to raise_error
        end
      end
    end

    after do
      client.close_session(session_id)
      channel_client.delete_channel(uri)
    end
  end
end
