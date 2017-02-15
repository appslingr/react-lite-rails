# Override setting set in application.rb
class CustomComponentMount < ReactLite::Rails::ComponentMount
end

Dummy::Application.configure do
  config.react.addons = true
  config.react.view_helper_implementation = CustomComponentMount
end

