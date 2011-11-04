require 'spec_helper'

describe Isbm::Config do
  before do
    ENV["RACK_ENV"] = "test"
  end

  context "when config file is loaded" do
    before do
      Isbm::Config::load!(File.join("spec","fixtures","isbm.yml"))
    end

    it "collects settings" do
      Isbm::Config.settings.should == {
        :provider_publication => "pro.wsdl",
        :channel_management => "chan.wsdl",
        :logging => true,
        :send_log_to_railslog => true
      }
    end

    it "has chan_man endpoint" do
      Isbm::Config.channel_management_endpoint.should == "chan.wsdl"
    end

    it "has provider_publication endpoint" do
      Isbm::Config.provider_publication_endpoint.should == "pro.wsdl"
    end
  end
end
