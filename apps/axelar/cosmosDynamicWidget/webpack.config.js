var path = require("path");
var webpack = require("webpack");

module.exports = {
  entry: path.join(__dirname, "srcjs", "dynamic_button.jsx"),
  output: {
    path: path.join(__dirname, "inst/www/cosmosDynamicWidget/dynamic_button"),
    filename: "dynamic_button.js",
  },
  module: {
    rules: [
      {
        test: /\.jsx?$/,
        loader: "babel-loader",
        options: {
          presets: ["@babel/preset-env", "@babel/preset-react"],
        },
      },
      // For CSS so that import "path/style.css"; works
      {
        test: /\.css$/,
        use: ["style-loader", "css-loader"],
      },
    ],
  },
  externals: {
    react: "window.React",
    "react-dom": "window.ReactDOM",
    reactR: "window.reactR",
  },
  stats: {
    colors: true,
  },
  devtool: "source-map",
  //   resolve: {
  //     fallback: {
  //       crypto: false,
  //       stream: require.resolve("stream-browserify"),
  //     },
  //   },
  plugins: [
    new webpack.ProvidePlugin({
      process: "process/browser",
      Buffer: ["buffer", "Buffer"],
    }),
  ],
  node: {
    crypto: false, //"empty",
    stream: true, //require.resolve("stream-browserify"),
  },
};
