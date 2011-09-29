require "isbm/version"
require "savon"

module Isbm
  autoload :ChannelManagement, 'isbm/channel_management'

  def self.included(base)
      base.class_eval do
        include InstanceMethods
        extend ClassMethods
      end
    end
  module ClassMethods
    def was_successful(response)
      return (!response.empty? && response[:transaction_status][:success_or_error_criteria] == "0" )? true : false 
    end

    def isbm_channel_man
      Savon::Client.new {
        wsdl.document = "wsdls/ISBMChannelManagementService.wsdl"
        wsdl.endpoint = "http://172.16.72.31:9080/IsbmModuleWeb/sca/ISBMChannelManagementServiceSoapExport"
      }
    end

    # Required for UC1
    def isbm_providor_pub
      Savon::Client.new {
        wsdl.document = "wsdls/ISBMConsumerRequestService.wsdl"
        wsdl.endpoint = "http://172.16.72.31:9080/IsbmModuleWeb/sca/ISBMProviderPublicationServiceSoapExport"
      }
    end

    def isbm_consumer_pub
      Savon::Client.new {
        wsdl.document = "wsdls/ISBMConsumerPublicationService.wsdl"
        wsdl.endpoint = "http://172.16.72.31:9080/IsbmModuleWeb/sca/ISBMConsumerPublicationServiceSoapExport"
      }
    end

    def isbm_notification_client
      Savon::Client.new {
        wsdl.document = "wsdls/ISBMNotifyListenerService.wsdl"
        wsdl.endpoint = "http://172.16.72.31:9080/IsbmCustomerABCWeb/sca/ISBMNotifyListenerServiceSoapExport"
      }
    end

  end
  module InstanceMethods
  end
end
