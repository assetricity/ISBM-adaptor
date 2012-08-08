require 'rubygems'

# Not run with spec_helper in order to test default config values
describe Isbm::Config do
  before do
    ENV["RACK_ENV"] = "test"
  end

  context "when config file is loaded" do
    before(:all) do
      Isbm::Config::clear
      Isbm::Config::load(File.join("spec","fixtures","isbm.yml"))
    end

    it "has channel management endpoint" do
      Isbm::Config.channel_management_endpoint.should eq "http://localhost/ChannelManagementService"
    end

    it "has provider_publication endpoint" do
      Isbm::Config.provider_publication_endpoint.should be_nil
    end

    it "has no consumer_publication endpoint" do
      Isbm::Config.consumer_publication_endpoint.should be_nil
    end

    it "has logging enabled" do
      Isbm::Config.log.should be_true
    end

    it "has pretty print xml disabled by default" do
      Isbm::Config.pretty_print_xml.should be_false
    end

    it "has rails logging disabled" do
      Isbm::Config.use_rails_logger.should be_false
    end
  end

  after(:all) do
    Isbm::Config::clear
    Isbm::Config.load(File.join("config", "isbm.yml")) # Reload normal test config as this spec will overwrite values
  end
end
