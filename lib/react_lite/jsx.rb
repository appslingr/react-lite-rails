require 'react_lite/jsx/processor'
require 'react_lite/jsx/template'
require 'react_lite/jsx/jsx_transformer'
require 'react_lite/jsx/babel_transformer'
require 'react_lite/jsx/sprockets_strategy'
require 'rails'

module ReactLite
  module JSX
    DEFAULT_TRANSFORMER = BabelTransformer
    mattr_accessor :transform_options, :transformer_class, :transformer

    # You can assign `config.react.jsx_transformer_class = `
    # to provide your own transformer. It must implement:
    # - #initialize(options)
    # - #transform(code) => new code
    self.transformer_class = DEFAULT_TRANSFORMER

    def self.transform(code)
      self.transformer ||= transformer_class.new(transform_options)
      self.transformer.transform(code)
    end
  end
end
