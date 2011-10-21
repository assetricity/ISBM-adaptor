require "isbm/version"
require "savon"
require "log_buddy"
require "savon_model"

module Isbm
  autoload :ChannelManagement, 'isbm/channel_management'
  autoload :ProviderPublication, 'isbm/provider_publication'
  autoload :Channel, 'isbm/channel'

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
      @logger ||= ::Logger.new STDOUT
    end
  end

  module ClassMethods
    private
    def validate_presense_of(given_arguments, *args)
      args.each { |arg| raise Isbm::ArgumentError if given_arguments.first[arg].nil? }
    end
  end
  module InstanceMethods
  end
end
