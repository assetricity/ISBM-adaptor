module Isbm
  module Config
    class << self
      # Load the settings from a compliant isbm.yml file
      # 'path' is a string path to the file
      def load(path, environment)
        settings = YAML.load_file(path) || {}
        from_hash(settings[environment] || {})
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

      def from_hash(config)
        @settings = {}
        define_endpoints(config["endpoints"] || {})
        define_options(config["options"] || {})
      end

      def define_options(options = {})
        options.each{ |name, value| @settings[name.to_sym] = value }
      end

      def define_endpoints(endpoints = {})
        endpoints.each{ |type, endpoint| @settings[type.to_sym] = endpoint}
      end

      def configure_savon
        # Configure HTTPI
        HTTPI.log = log
        HTTPI.logger = Rails.logger if use_rails_logger && defined?(Rails)

        # Configure Savon
        Savon.configure do |config|
          config.log = log
          config.pretty_print_xml = pretty_print_xml
          config.logger = Rails.logger if use_rails_logger && defined?(Rails)
        end
      end
    end
  end
end
