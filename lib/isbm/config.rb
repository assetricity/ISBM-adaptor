module Isbm
  module Config
    class << self
      # Load the settings from a compliant isbm.yml file
      # 'path' is a string path to the file
      def load(path)
        environment = defined?(Rails) && Rails.respond_to?(:env) ? Rails.env : ENV["RACK_ENV"]
        settings = YAML.load(File.new(path).read)[environment]
        unless settings.blank?
          from_hash(settings)
        end
        configure_savon
      end

      # Defined in YAML at environment->endpoints->channel_management
      def channel_management_endpoint
        @settings[:channel_management]
      end

      # Defined in YAML at environment->endpoints->provider_publication
      def provider_publication_endpoint
        @settings[:provider_publication]
      end

      # Defined in YAML at environment->endpoints->consumer_publication
      def consumer_publication_endpoint
        @settings[:consumer_publication]
      end

      # Defined in YAML at environment->log
      def log
        @settings[:log] || false
      end

      # Defined in YAML at environment->pretty_print_xml
      def pretty_print_xml
        @settings[:pretty_print_xml] || false
      end

      # Defined in YAML at environment->use_rails_logger
      def use_rails_logger
        @settings[:use_rails_logger] || false
      end

      # Delete all settings
      def clear
        @settings = {}
      end

      private

      def from_hash(options)
        @settings ||= {}
        options.each do |name, value|
          # Flatten endpoint hash
          if name == "endpoints"
            options[name].each do |type, endpoint|
              @settings[type.to_sym] = endpoint
            end
          else
            @settings[name.to_sym] = value
          end
        end
      end

      def configure_savon
        HTTPI.log = log
        Savon.configure do |config|
          config.log = log
          config.pretty_print_xml = pretty_print_xml
          config.logger = Rails.logger if use_rails_logger && defined?(Rails)
        end
      end
    end
  end
end
