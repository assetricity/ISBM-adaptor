require "isbm/version"
require "savon"
require "log_buddy"

module Isbm
  autoload :ChannelManagement, 'isbm/channel_management'
  autoload :ProviderPublication, 'isbm/provider_publication'

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
  end

  module ClassMethods
    def isbm_channel_man
      Savon::Client.new {
        wsdl.document = "wsdls/ISBMChannelManagementService.wsdl"
        wsdl.endpoint = "http://172.16.72.31:9080/IsbmModuleWeb/sca/ISBMChannelManagementServiceSoapExport"
      }
    end

    # Required for UC1
    def isbm_provider_pub
      Savon::Client.new {
        wsdl.document = "wsdls/ISBMConsumerRequestService.wsdl"
        wsdl.endpoint = "http://172.16.72.31:9080/IsbmModuleWeb/sca/ISBMProviderPublicationServiceSoapExport"
      }
    end

    private
    def validate_presense_of(given_arguments, *args)
      args.each { |arg| raise Isbm::ArgumentError if given_arguments.first[arg].nil? }
    end
  end
  module InstanceMethods
  end
end
