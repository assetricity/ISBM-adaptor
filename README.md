# ISBM Adaptor

[![Build Status](https://app.travis-ci.com/assetricity/isbm_adaptor.svg?branch=master)](https://app.travis-ci.com/assetricity/isbm_adaptor)
[![Coverage Status](https://coveralls.io/repos/assetricity/isbm_adaptor/badge.svg?branch=master)](https://coveralls.io/r/assetricity/isbm_adaptor?branch=master)
[![Code Climate](https://codeclimate.com/github/assetricity/isbm_adaptor.svg)](https://codeclimate.com/github/assetricity/isbm_adaptor)
[![Dependency Status](https://gemnasium.com/assetricity/isbm_adaptor.svg)](https://gemnasium.com/assetricity/isbm_adaptor)

The ISBM Adaptor provides a Ruby API for the [OpenO&M ws-ISBM specification](http://www.openoandm.org/ws-isbm).

It is based on the [Savon](http://savonrb.com) SOAP client and provides convenience methods for interaction with an ws-ISBM Service Provider.

## Install

### Bundler

Add to the isbm_adaptor gem to your Gemfile:

```ruby
gem 'isbm_adaptor'
```

This gem uses a three part version, with the first two parts following the OpenO&M ws-ISBM specification and last part specifying a patch number. To use the pessimistic version constraint, you will want to include the three part version in your Gemfile:

```ruby
gem 'isbm_adaptor', '~> 1.0.0'
```

### Other

The gem can also be installed via the gem install command:

```bash
gem install isbm_adaptor
```

## Usage

Create a client object by specifying an endpoint. For example:

```ruby
client = IsbmAdaptor::ChannelManagement.new('http://example.com/ChannelManagement')
```

The standard [Savon options](http://savonrb.com/version2/globals.html) can also be passed to the client upon creation. For example:

```ruby
client = IsbmAdaptor::ChannelManagement.new('http://example.com/ChannelManagement', log: true)
```

Use the client methods to directly send SOAP messages to the server. For example:

```ruby
client.get_channels
```

### Publish/Subscribe Example

The following shows an example of creating a publication channel, subscribing to the channel and posting a message on the channel.

```ruby
require 'isbm_adaptor'

channel_management_endpoint = 'http://example.com/ChannelManagement'
consumer_publication_endpoint = 'http://example.com/ConsumerPublication'
provider_publication_endpoint = 'http://example.com/ProviderPublication'

uri = 'unique/publication/uri'
topic = 'unique/topic'
message_content = '<message/>'

channel_client = IsbmAdaptor::ChannelManagement.new(channel_management_endpoint)
channel_client.create_channel(uri, :publication)

subscribe_client = IsbmAdaptor::ConsumerPublication.new(consumer_publication_endpoint)
subscribe_session_id = subscribe_client.open_session(uri, [topic])

publish_client = IsbmAdaptor::ProviderPublication.new(provider_publication_endpoint)
publish_session_id = publish_client.open_session(uri)
publish_client.post_publication(publish_session_id, message_content, topic)

message = subscribe_client.read_publication(subscribe_session_id)
puts message.content.to_s

publish_client.close_session(publish_session_id)
subscribe_client.close_session(subscribe_session_id)
channel_client.delete_channel(uri)
```

### Request/Response Example

The following shows an example of creating a request channel, sending a request and then sending a response.

```ruby
require 'isbm_adaptor'

channel_management_endpoint = 'http://example.com/ChannelManagement'
provider_request_endpoint = 'http://example.com/ProviderRequest'
consumer_request_endpoint = 'http://example.com/ConsumerRequest'

uri = 'unique/request/uri'
topic = 'unique/topic'
request_content = '<request/>'
response_content = '<response/>'

channel_client = IsbmAdaptor::ChannelManagement.new(channel_management_endpoint)
channel_client.create_channel(uri, :request)

response_client = IsbmAdaptor::ProviderRequest.new(provider_request_endpoint)
response_session_id = response_client.open_session(uri, [topic])

request_client =  IsbmAdaptor::ConsumerRequest.new(consumer_request_endpoint)
request_session_id = request_client.open_session(uri)
request_message_id = request_client.post_request(request_session_id, request_content, topic)

request_message = response_client.read_request(response_session_id)
puts request_message.content.to_s
response_client.remove_request(response_session_id)
response_client.post_response(response_session_id, request_message.id, response_content)

response_message = request_client.read_response(request_session_id, request_message_id)
puts response_message.content.to_s
request_client.remove_response(request_session_id, request_message_id)

request_client.close_session(request_session_id)
response_client.close_session(response_session_id)
channel_client.delete_channel(uri)
```

## License

Copyright 2014 [Assetricity, LLC](http://assetricity.com)

ISBM Adaptor is released under the MIT License. See [LICENSE](https://github.com/assetricity/isbm_adaptor/blob/master/LICENSE) for details.
