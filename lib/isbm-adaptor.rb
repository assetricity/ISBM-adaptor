require 'active_support/core_ext/object/blank'
require 'isbm-adaptor/version'
require 'savon'

module IsbmAdaptor
  autoload :ChannelManagement, 'isbm-adaptor/channel_management'
  autoload :ProviderPublication, 'isbm-adaptor/provider_publication'
  autoload :ConsumerPublication, 'isbm-adaptor/consumer_publication'
  autoload :Duration, 'isbm-adaptor/duration'
end
