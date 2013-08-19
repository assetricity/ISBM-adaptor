require 'spec_helper'

describe IsbmAdaptor::ChannelManagement, :vcr do
  let(:uri) { 'Test' }
  let(:type) { :publication }
  let(:description) { 'description' }
  let(:client) { IsbmAdaptor::ChannelManagement.new(ENDPOINTS['channel_management'], OPTIONS) }

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

    describe '#get_channel' do
      it 'raises error with no URI' do
        expect { client.get_channel(nil) }.to raise_error ArgumentError
      end
    end

    describe '#delete_channel' do
      it 'raises error with no URI' do
        expect { client.delete_channel(nil) }.to raise_error ArgumentError
      end
    end
  end

  context 'when valid arguments' do
    before { client.create_channel(uri, type, description) }

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
