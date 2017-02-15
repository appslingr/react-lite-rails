class ServerController < ApplicationController
  def show
    @todos = %w{todo1 todo2 todo3}
  end

  def console_example
    ReactLite::ServerRendering.renderer_options = {replay_console:  true}
    ReactLite::ServerRendering.reset_pool
    @todos = %w{todo1 todo2 todo3}
  end

  def console_example_suppressed
    ReactLite::ServerRendering.renderer_options = {replay_console:  false}
    ReactLite::ServerRendering.reset_pool
    @todos = %w{todo1 todo2 todo3}
  end

  def inline_component
    render component: 'TodoList',
           props: { todos: ['Render this inline'] },
           tag: 'span',
           class: 'custom-class',
           id: 'custom-id',
           data: { remote: true }
  end
end
