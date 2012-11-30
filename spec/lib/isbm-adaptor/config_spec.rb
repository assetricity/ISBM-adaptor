require "spec_helper"

# Not run with spec_helper in order to test default config values
describe IsbmAdaptor::Config do
  context "when the config file is invalid" do
    before(:all) do
      IsbmAdaptor::Config::clear
      config_isbm(File.join("spec","fixtures","badconfig.yml"))
    end

    it "give nil for all endpoints" do
      IsbmAdaptor::Config.channel_management_endpoint.should be_nil
      IsbmAdaptor::Config.provider_publication_endpoint.should be_nil
      IsbmAdaptor::Config.consumer_publication_endpoint.should be_nil
    end

    it "gives nil for all standard options" do
      IsbmAdaptor::Config.log.should be_false
      IsbmAdaptor::Config.pretty_print_xml.should be_false
      IsbmAdaptor::Config.use_rails_logger.should be_false
    end
  end

  context "when config file is loaded" do
    before(:all) do
      IsbmAdaptor::Config::clear
      config_isbm(File.join("spec","fixtures","isbm.yml"))
    end

    it "has channel management endpoint" do
      IsbmAdaptor::Config.channel_management_endpoint.should eq "http://localhost/ChannelManagementService"
    end

    it "has provider_publication endpoint" do
      IsbmAdaptor::Config.provider_publication_endpoint.should be_nil
    end

    it "has no consumer_publication endpoint" do
      IsbmAdaptor::Config.consumer_publication_endpoint.should be_nil
    end

    it "has logging enabled" do
      IsbmAdaptor::Config.log.should be_true
    end

    it "has pretty print xml disabled by default" do
      IsbmAdaptor::Config.pretty_print_xml.should be_false
    end

    it "has rails logging disabled" do
      IsbmAdaptor::Config.use_rails_logger.should be_false
    end
  end

  after(:all) do
    IsbmAdaptor::Config::clear
    config_isbm(File.join("config", "isbm.yml")) # Reload normal test config as this spec will overwrite values
  end
end
