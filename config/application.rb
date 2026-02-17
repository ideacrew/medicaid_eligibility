require_relative "boot"

require "rails/all"

# Require the gems listed in Gemfile, including any gems
# you've limited to :test, :development, or :production.
Bundler.require(*Rails.groups)

module MedicaidEligibilityApi
  class Application < Rails::Application
    # Initialize configuration defaults for originally generated Rails version.
    config.load_defaults 5.0

    # Please, add to the `ignore` list any other `lib` subdirectories that do
    # not contain `.rb` files, or that should not be reloaded or eager loaded.
    # Common ones are `templates`, `generators`, or `middleware`, for example.
    config.autoload_lib(ignore: %w[assets tasks])

    # Configuration for the application, engines, and railties goes here.
    #
    # These settings can be overridden in specific environments using the files
    # in config/environments, which are processed later.
    #
    # config.time_zone = "Central Time (US & Canada)"
    # config.eager_load_paths << Rails.root.join("extras")

    # Enable escaping HTML in JSON.
    config.active_support.escape_html_entities_in_json = true

    config.assets.configure do |env|
      env.cache = ActiveSupport::Cache::MemoryStore.new
    end

    def options
      self.class.options
    end

    def self.options
      begin
        @@options ||= {
          :state_config => JSON.parse!(File.read(Rails.root.join('config/state_config.json'))),
          :system_config => JSON.parse!(File.read(Rails.root.join('config/system_config.json'))),
          :ineligibility_reasons => YAML.load_file(Rails.root.join('config/code_explanation.yml'))
        }.with_indifferent_access
      rescue JSON::ParserError
        raise JSON::ParserError, "failed to parse config file"
      end
    end
  end
end
