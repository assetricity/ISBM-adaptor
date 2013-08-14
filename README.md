# ISBM Adaptor

[![travis](https://travis-ci.org/assetricity/isbm_adaptor.png)](https://travis-ci.org/assetricity/isbm_adaptor)
[![Coverage Status](https://coveralls.io/repos/assetricity/isbm_adaptor/badge.png?branch=master)](https://coveralls.io/r/assetricity/isbm_adaptor?branch=master)

The ISBM Adaptor provides a Ruby API for the [OpenO&M ISBM specification](http://www.mimosa.org/?q=about/what-open-om).

It is based on the [Savon](http://savonrb.com) SOAP client and provides convenience methods for interaction with an ISBM Service Provider.

## Install

### Bundler

Add to the isbm_adaptor gem to your Gemfile:

```ruby
gem 'isbm_adaptor'
```

This gem uses a four part version, with the first three parts following the OpenO&M ISBM specification and last part specifying a patch number. To use the pessimistic version constraint, you will want to include the four part version in your Gemfile:

```ruby
gem 'isbm_adaptor', '~> 1.0.0.0'
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

The standard Savon options can also be passed to the client upon creation. For example:

```ruby
client = IsbmAdaptor::ChannelManagement.new('http://example.com/ChannelManagement', log: false)
```

Use the client methods to directly send SOAP messages to the server. For example:

```ruby
client.get_channels
```

## License

Copyright 2013 Assetricity, LLC

ISBM Adaptor is released under the MIT License. See [LICENSE](https://github.com/assetricity/isbm_adaptor/blob/master/LICENSE) for details.
