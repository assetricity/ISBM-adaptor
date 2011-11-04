module Isbm
  module Config
    class << self
      attr_accessor :settings

      # Load the settings from a compliant isbm.yml file.
      #
      # @example Configure Isbm.
      #   Isbm.load!("/path/to/isbm.yml")
      #
      # @param [ String ] path The path to the file.
      def load!(path)
        environment = defined?(Rails) && Rails.respond_to?(:env) ? Rails.env : ENV["RACK_ENV"]
        settings = YAML.load(File.new(path).read)[environment]
        unless settings.blank?
          from_hash(settings)
        end
      end

      # Configure Isbm from a hash. This is usually called after parsing a
      # yaml config file such as isbm.yml.
      def from_hash(options = {})
        self.settings ||= {}
        options.reject{|key, value| key == 'endpoints'}.each_pair do |name, value|
          self.settings[name.to_sym] = value
        end
        options["endpoints"].each_pair do |name, value|
          self.settings[name.to_sym] = value
        end
      end

      def provider_publication_endpoint
        self.settings[:provider_publication]
      end

      def channel_management_endpoint
        self.settings[:channel_management]
      end
    end
  end
end
