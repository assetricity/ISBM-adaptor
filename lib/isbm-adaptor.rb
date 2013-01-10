require "isbm-adaptor/version"
require "isbm-adaptor/config"
require "savon"
require "isbm-adaptor/railtie" if defined?(Rails)

# Use NetHttp from Ruby instead of HTTPI
HTTPI.adapter = :net_http

module IsbmAdaptor
  autoload :ChannelManagement, "isbm-adaptor/channel_management"
  autoload :ProviderPublication, "isbm-adaptor/provider_publication"
  autoload :ConsumerPublication, "isbm-adaptor/consumer_publication"
  autoload :Duration, "isbm-adaptor/duration"

  def self.included(base)
    base.class_eval do
      extend ClassMethods
    end
  end

  module ClassMethods
    private

    def wsdl_dir
      ( File.expand_path File.dirname(__FILE__) ) + "/../wsdls/"
    end

    def isbm_namespace
      "http://www.openoandm.org/xml/ISBM/"
    end

    # XML Builder can only set a namespace by prefix, so for simplicity, use a default namespace
    def set_default_namespace(soap)
      soap.namespaces["xmlns"] = isbm_namespace
    end
  end
end
