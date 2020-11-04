require_relative 'boot'

require 'rails/all'

# Require the gems listed in Gemfile, including any gems
# you've limited to :test, :development, or :production.
Bundler.require(*Rails.groups)

module Hospital
  class Application < Rails::Application
    # Initialize configuration defaults for originally generated Rails version.
    config.load_defaults 5.2

    # Make Active Record use stable #cache_key alongside new #cache_version method.
# This is needed for recyclable cache keys.
    Rails.application.config.active_record.cache_versioning = true
    
    # Add default protection from forgery to ActionController::Base instead of in
# ApplicationController.
    Rails.application.config.action_controller.default_protect_from_forgery = true

    # Use SHA-1 instead of MD5 to generate non-sensitive digests, such as the ETag header.
    Rails.application.config.active_support.use_sha1_digests = true

    # Settings in config/environments/* take precedence over those specified here.
    # Application configuration can go into files in config/initializers
    # -- all .rb files in that directory are automatically loaded after loading
    # the framework and any gems in your application.
  end
end
