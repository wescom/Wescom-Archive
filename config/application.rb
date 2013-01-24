require File.expand_path('../boot', __FILE__)

require 'rails/all'

if defined?(Bundler)
  # If you precompile assets before deploying to productiona, use this line
  Bundler.require *Rails.groups(:assets => %w(development test))
  # If you want your assets lazily compiled in production, use this line
  # Bundler.require(:default, :assets, Rails.env)
end

module Wescomarchive
  class Application < Rails::Application
    # config.autoload_paths += %W(#{config.root}/extras)

    # config.plugins = [ :exception_notification, :ssl_requirement, :all ]

    # config.active_record.observers = :cacher, :garbage_collector, :forum_observer

    config.time_zone = 'Pacific Time (US & Canada)'

    # config.i18n.load_path += Dir[Rails.root.join('my', 'locales', '*.{rb,yml}').to_s]
    # config.i18n.default_locale = :de

    # config.action_view.javascript_expansions[:defaults] = %w(jquery rails)

    # Configure the default encoding used in templates for Ruby 1.9.
    config.encoding = "utf-8"

    # Configure sensitive parameters which will be filtered from the log file.
    config.filter_parameters += [:password]

    # Enable the asset pipeline
    config.assets.enabled = true
    config.assets.precompile += ['*.css', '*.js'] 

    # Version of your assets, change this if you want to expire all your assets  
    config.assets.version = '2.1'
  end
end
