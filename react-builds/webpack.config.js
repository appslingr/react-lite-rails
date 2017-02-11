// Use `rake react:update` to build this bundle & copy files into the gem.
var webpack = require("webpack");

var reactRailsEnv = process.env.NODE_ENV == "production" ? "production" : "development";

var plugins = [];

if (reactRailsEnv == "production") {
  var definePlugin = new webpack.DefinePlugin({'process.env.NODE_ENV': '"production"'});
  var minifyPlugin = new webpack.optimize.UglifyJsPlugin({
    compress: {
        warnings: false
    }
  });
  plugins.push(definePlugin);
  plugins.push(minifyPlugin);
}


module.exports = {
  context: __dirname,
  entry: {
    "react-lite-browser": "./react-lite-browser.js",
    "react-lite-browser-with-addons": "./react-lite-browser-with-addons.js"
  },
  output: {
      path: __dirname + "/build/" + reactRailsEnv,
      filename: "[name].js",
  },
  plugins: plugins,
};
