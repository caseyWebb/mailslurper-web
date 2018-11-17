"use strict";

const HtmlPlugin = require("html-webpack-plugin");
const UglifyPlugin = require("uglifyjs-webpack-plugin");

const PRODUCTION = process.env.NODE_ENV === "production";

module.exports = {
  mode: PRODUCTION ? "production" : "development",

  devServer: {
    historyApiFallback: true,
    hot: true,
    quiet: true
  },

  optimization: {
    minimizer: [
      new UglifyPlugin({
        uglifyOptions: {
          compress: {
            pure_funcs: [
              "F2",
              "F3",
              "F4",
              "F5",
              "F6",
              "F7",
              "F8",
              "F9",
              "A2",
              "A3",
              "A4",
              "A5",
              "A6",
              "A7",
              "A8",
              "A9"
            ],
            pure_getters: true,
            keep_fargs: false,
            unsafe_comps: true,
            unsafe: true
          }
        }
      })
    ]
  },

  module: {
    rules: [
      {
        test: /\.elm$/,
        use: [
          { loader: "elm-hot-webpack-loader" },
          {
            loader: "elm-webpack-loader",
            options: {
              debug: !PRODUCTION,
              optimize: PRODUCTION,
              verbose: true
            }
          }
        ]
      }
    ],

    noParse: /\.elm$/
  },

  plugins: [new HtmlPlugin()],

  resolve: {
    extensions: [".js", ".elm"]
  }
};
