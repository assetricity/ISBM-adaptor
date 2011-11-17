require "isbm/version"
require "savon"
require "savon_model"

# Use NetHttp from Ruby instead of HTTPI
HTTPI.adapter = :net_http

if defined?(Rails)
  require "isbm/railtie"
end

module Isbm
  autoload :ChannelManagement, 'isbm/channel_management'
  autoload :ProviderPublication, 'isbm/provider_publication'
  autoload :Channel, 'isbm/channel'
  autoload :Topic, 'isbm/topic'
  autoload :Session, 'isbm/session'
  autoload :Config, 'isbm/config'

  class ArgumentError < RuntimeError; end

  def self.included(base)
    base.class_eval do
      include InstanceMethods
      extend ClassMethods
    end
  end

  class << self
    def was_successful(response)
      return (!response.empty? && response[:transaction_status][:success_or_error_criteria] == "0" )? true : false
    end

    def get_status_message(response)
      return response[:transaction_status][:status_message]
    end

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
    def validate_presense_of(given_arguments, *args)
      calling_method = /`(.*)'/.match(caller[0])
      calling_parent = caller[1]
      args.each do |arg| 
        if given_arguments.first[arg].nil?
          raise ArgumentError.new "#{calling_method} requires #{arg} \n#{calling_parent}"
        end
      end
    end
  end
  module InstanceMethods
  end
end
