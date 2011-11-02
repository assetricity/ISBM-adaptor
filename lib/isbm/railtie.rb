require "singleton"
require "isbm"
require "isbm/railties/document"
require "rails"
require "rails/mongoid"

module Rails
  module Isbm
    class Railtie < Rails::Railtie
      # After initialization we will warn the user if we can't find a mongoid.yml and
      # alert to create one.
      initializer "warn when configuration is missing" do
        config.after_initialize do
          unless Rails.root.join("config", "isbm.yml").file?
            puts "\nIsbm config not found. Create a config file at: config/isbm.yml"
            puts "to generate one run: rails generate isbm:config\n\n"
          end
        end
      end
    end
  end
end
