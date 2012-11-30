require "rails"
require "isbm-adaptor"
require "isbm-adaptor/config"

module IsbmAdaptor
  class Railtie < Rails::Railtie

    def self.generator
      config.respond_to?(:app_generators) ? :app_generators : :generators
    end

    config.isbm = IsbmAdaptor::Config

    initializer "setup database" do
      config_file = Rails.root.join("config", "isbm.yml")
      if config_file.file? && YAML.load(File.read(config_file))[Rails.env].values.flatten.any?
        IsbmAdaptor::Config.load(config_file, Rails.env)
      else
      end
    end

    # After initialization we will warn the user if we can"t find a isbm.yml and
    # alert to create one.
    initializer "warn when configuration is missing" do
      config.after_initialize do
        unless Rails.root.join("config", "isbm.yml").file?
          puts "\nIsbm config not found. Create a config file at: config/isbm.yml"
          puts "to generate one run: rails generate isbmadaptor:config\n\n"
        end
      end
    end
  end
end
