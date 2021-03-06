require 'rails'

module ReactLite
  module Rails
    class Railtie < ::Rails::Railtie
      config.react = ActiveSupport::OrderedOptions.new
      # Sensible defaults. Can be overridden in application.rb
      config.react.variant = (::Rails.env.production? ? :production : :development)
      config.react.addons = false
      config.react.jsx_transform_options = {}
      config.react.jsx_transformer_class = nil # defaults to BabelTransformer
      config.react.camelize_props = false # pass in an underscored hash but get a camelized hash
      config.react.sprockets_strategy = nil # how to attach JSX to the asset pipeline (or `false` for none)

      # View helper implementation:
      config.react.view_helper_implementation = nil # Defaults to ComponentMount

      # Watch .jsx files for changes in dev, so we can reload the JS VMs with the new JS code.
      initializer "react_rails.add_watchable_files", group: :all do |app|
        app.config.watchable_files.concat Dir["#{app.root}/app/assets/javascripts/**/*.jsx*"]
      end

      # Include the react-rails view helper lazily
      initializer "react_rails.setup_view_helpers", after: :load_config_initializers, group: :all do |app|

        app.config.react.jsx_transformer_class ||= ReactLite::JSX::DEFAULT_TRANSFORMER
        ReactLite::JSX.transformer_class = app.config.react.jsx_transformer_class
        ReactLite::JSX.transform_options = app.config.react.jsx_transform_options

        app.config.react.view_helper_implementation ||= ReactLite::Rails::ComponentMount
        ReactLite::Rails::ViewHelper.helper_implementation_class = app.config.react.view_helper_implementation
        ReactLite::Rails::ComponentMount.camelize_props_switch = app.config.react.camelize_props

        ActiveSupport.on_load(:action_controller) do
          include ::ReactLite::Rails::ControllerLifecycle
        end

        ActiveSupport.on_load(:action_view) do
          include ::ReactLite::Rails::ViewHelper
        end
      end

      initializer "react_rails.add_component_renderer", group: :all do |app|
        ActionController::Renderers.add :component do |component_name, options|
          renderer = ::ReactLite::Rails::ControllerRenderer.new(controller: self)
          html = renderer.call(component_name, options)
          render_options = options.merge(inline: html)
          render(render_options)
        end
      end

      initializer "react_rails.bust_cache", after: :load_config_initializers, group: :all do |app|
        asset_variant = ReactLite::Rails::AssetVariant.new({
          variant: app.config.react.variant,
          addons: app.config.react.addons,
        })

        sprockets_env = app.assets || app.config.try(:assets) # sprockets-rails 3.x attaches this at a different config
        if !sprockets_env.nil?
          sprockets_env.version = [sprockets_env.version, "react-#{asset_variant.react_build}",].compact.join('-')
        end

      end

      initializer "react_rails.set_variant", after: :engines_blank_point, group: :all do |app|
        asset_variant = ReactLite::Rails::AssetVariant.new({
          variant: app.config.react.variant,
          addons: app.config.react.addons,
        })

        if app.config.respond_to?(:assets)
          app.config.assets.paths << asset_variant.react_directory
          app.config.assets.paths << asset_variant.jsx_directory
        end
      end

      config.after_initialize do |app|

      end

      initializer "react_rails.setup_engine", :group => :all do |app|
        # Sprockets 3.x expects this in a different place
        sprockets_env = app.assets || defined?(Sprockets) && Sprockets

        if app.config.react.sprockets_strategy == false
          # pass, Sprockets opt-out
        elsif sprockets_env.present?
          ReactLite::JSX::SprocketsStrategy.attach_with_strategy(sprockets_env, app.config.react.sprockets_strategy)
        else
          # pass, Sprockets is not preset
        end
      end
    end
  end
end
