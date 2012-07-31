require "isbm/version"
require "savon"

# Use NetHttp from Ruby instead of HTTPI
HTTPI.adapter = :net_http

if defined?(Rails)
  require "isbm/railtie"
end

module Isbm
  autoload :ChannelManagement, 'isbm/channel_management'
  autoload :ProviderPublication, 'isbm/provider_publication'
  autoload :ConsumerPublication, 'isbm/consumer_publication'
  autoload :Config, 'isbm/config'
  autoload :Duration, 'isbm/duration'

  class ArgumentError < RuntimeError; end

  def self.included(base)
    base.class_eval do
      include InstanceMethods
      extend ClassMethods
    end
  end

  class << self
    # Sets the logger to use.
    attr_writer :logger

    # Returns the logger. Defaults to an instance of +Logger+ writing to STDOUT.
    def logger
      @logger ||= ::Logger.new STDERR
    end

    def wsdl_dir
      ( File.expand_path File.dirname(__FILE__) ) + "/../wsdls/"
    end
  end

  module ClassMethods
    private
    def isbm_namespace
      "http://www.openoandm.org/xml/ISBM/"
    end

    # XML Builder can only set a namespace by prefix, so for simplicity, use a default namespace
    def set_default_namespace(soap)
      soap.namespaces["xmlns"] = isbm_namespace
    end
  end
  module InstanceMethods
    Gyoku.convert_symbols_to :camelcase
  end
end
