require 'spec_helper'

describe IsbmAdaptor::ChannelManagement, :vcr do
  let(:uri) { 'Test' }
  let(:type) { :publication }
  let(:description) { 'description' }
  let(:tokens) { {u1: :p1, u2: :p2} }
  let(:client) do
    options = OPTIONS.merge(wsse_auth: ['u1', 'p1'])
    IsbmAdaptor::ChannelManagement.new(ENDPOINTS['channel_management'], options)
  end

  context 'when invalid arguments' do
    describe '#create_channel' do
      it 'raises error with no URI' do
        expect { client.create_channel(nil, type) }.to raise_error ArgumentError
      end

      it 'raises error with no type' do
        expect { client.create_channel(uri, nil) }.to raise_error ArgumentError
      end

      it 'raises error with incorrect type' do
        expect { client.create_channel(uri, :invalid_channel_type) }.to raise_error ArgumentError
      end
    end

    describe '#add_security_tokens' do
      it 'raises error with no URI' do
        expect { client.add_security_tokens(nil, tokens) }.to raise_error ArgumentError
      end

      it 'raises error with no tokens' do
        expect { client.add_security_tokens(uri, nil) }.to raise_error ArgumentError
      end
    end

    describe '#remove_security_tokens' do
      it 'raises error with no URI' do
        expect { client.remove_security_tokens(nil, tokens) }.to raise_error ArgumentError
      end

      it 'raises error with no tokens' do
        expect { client.remove_security_tokens(uri, nil) }.to raise_error ArgumentError
      end
    end

    describe '#delete_channel' do
      it 'raises error with no URI' do
        expect { client.delete_channel(nil) }.to raise_error ArgumentError
      end
    end

    describe '#get_channel' do
      it 'raises error with no URI' do
        expect { client.get_channel(nil) }.to raise_error ArgumentError
      end
    end
  end

  context 'when valid arguments' do
    before { client.create_channel(uri, type, description, tokens) }

    describe '#add_security_token' do
      it 'does not raise error' do
        expect { client.add_security_tokens(uri, tokens) }.not_to raise_error
      end
    end

    describe '#remove_security_token' do
      before { client.add_security_tokens(uri, tokens) }
      it 'does not raise error' do
        expect { client.remove_security_tokens(uri, tokens) }.not_to raise_error
      end
    end

    describe '#get_channel' do
      let(:channel) { client.get_channel(uri) }
      it 'returns a valid channel' do
        channel.uri.should == uri
        channel.type.should == type.to_s.capitalize
        channel.description.should == description
      end
    end

    describe '#get_channels' do
      let(:channels) { client.get_channels }
      it 'returns an array of valid channels' do
        (channel = channels.find { |channel| channel.uri == uri }).should_not be_nil
        channel.type.should == type.to_s.capitalize
        channel.description.should == description
      end
    end

    after { client.delete_channel(uri) }
  end
end
