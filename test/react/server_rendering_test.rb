require 'test_helper'

class NullRenderer
  def initialize(options)
    # in this case, options is actually a string (just for testing)
    @name = options
  end

  def render(component_name, props, prerender_options)
    "#{@name} rendered #{component_name} with #{props} and #{prerender_options}"
  end
end

class ReactServerRenderingTest < ActiveSupport::TestCase
  setup do
    @previous_renderer = ReactLite::ServerRendering.renderer
    @previous_options = ReactLite::ServerRendering.renderer_options
    ReactLite::ServerRendering.renderer_options = "TEST"
    ReactLite::ServerRendering.renderer = NullRenderer
    ReactLite::ServerRendering.reset_pool
  end

  teardown do
    ReactLite::ServerRendering.renderer = @previous_renderer
    ReactLite::ServerRendering.renderer_options = @previous_options
    ReactLite::ServerRendering.reset_pool
  end

  test '.create_renderer makes a renderer with initialization options' do
    mock_renderer = Minitest::Mock.new
    mock_renderer.expect(:new, :fake_renderer, [{mock: true}])
    ReactLite::ServerRendering.renderer = mock_renderer
    ReactLite::ServerRendering.renderer_options = {mock: true}
    renderer = ReactLite::ServerRendering.create_renderer
    assert_equal(:fake_renderer, renderer)
  end

  test '.render returns a rendered string' do
    props = {"props" => true}
    result = ReactLite::ServerRendering.render("MyComponent", props, "prerender-opts")
    assert_equal("TEST rendered MyComponent with #{props} and prerender-opts", result)
  end

  test '.reset_pool forgets old renderers' do
    # At first, they use the first options:
    assert_match(/^TEST/, ReactLite::ServerRendering.render(nil, nil, nil))
    assert_match(/^TEST/, ReactLite::ServerRendering.render(nil, nil, nil))

    # Then change the init options and clear the pool:
    ReactLite::ServerRendering.renderer_options = "DIFFERENT"
    ReactLite::ServerRendering.reset_pool
    # New renderers are created with the new init options:
    assert_match(/^DIFFERENT/, ReactLite::ServerRendering.render(nil, nil, nil))
    assert_match(/^DIFFERENT/, ReactLite::ServerRendering.render(nil, nil, nil))
  end
end