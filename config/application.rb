require_relative "boot"

require "rails/all"

# Require the gems listed in Gemfile, including any gems
# you've limited to :test, :development, or :production.
Bundler.require(*Rails.groups)

module Scriptures
  class Application < Rails::Application
    class << self
      delegate :credentials, to: :"Rails.application"
    end

    # Initialize configuration defaults for originally generated Rails version.
    config.load_defaults 8.1

    # Please, add to the `ignore` list any other `lib` subdirectories that do
    # not contain `.rb` files, or that should not be reloaded or eager loaded.
    # Common ones are `templates`, `generators`, or `middleware`, for example.
    config.autoload_lib(ignore: %w[assets tasks generators puma])

    # Configuration for the application, engines, and railties goes here.
    #
    # These settings can be overridden in specific environments using the files
    # in config/environments, which are processed later.
    #
    # config.time_zone = "Central Time (US & Canada)"
    # config.eager_load_paths << Rails.root.join("extras")

    # LLM provider API keys (ENV takes precedence over credentials)
    config.x.anthropic_api_key = ENV["ANTHROPIC_API_KEY"] || credentials.dig(:anthropic, :api_key)
    # https://platform.openai.com/api-keys
    config.x.openai_api_key = ENV["OPENAI_API_KEY"] || credentials.dig(:openai, :api_key)

    config.x.host = ENV["HOST"]

    config.x.smtp.from_address = ENV.fetch("SMTP_FROM_ADDRESS", "no-reply@scriptures.localhost")
    config.x.smtp.from_name = ENV.fetch("SMTP_FROM_NAME", "[Development] Scriptures")
    config.x.smtp.server_address = ENV.fetch("SMTP_SERVER_ADDRESS", credentials.smtp&.server_address)
    config.x.smtp.server_port = ENV.fetch("SMTP_SERVER_PORT", credentials.smtp&.server_port)
    config.x.smtp.user_name = ENV.fetch("SMTP_USER_NAME", credentials.smtp&.user_name)
    config.x.smtp.password = ENV.fetch("SMTP_PASSWORD", credentials.smtp&.password)

    config.x.s3.endpoint = ENV.fetch("S3_ENDPOINT", credentials.s3&.endpoint)
    config.x.s3.access_key_id = ENV.fetch("S3_ACCESS_KEY_ID", credentials.s3&.access_key_id)
    config.x.s3.secret_access_key = ENV.fetch("S3_SECRET_ACCESS_KEY", credentials.s3&.secret_access_key)
    config.x.s3.region = ENV.fetch("S3_REGION", credentials.s3&.region)
    config.x.s3.bucket = ENV.fetch("S3_BUCKET", credentials.s3&.bucket)
  end
end
