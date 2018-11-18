'use strict'

const TSCheckerPlugin = require('fork-ts-checker-webpack-plugin')
const HtmlPlugin = require('html-webpack-plugin')
const UglifyPlugin = require('uglifyjs-webpack-plugin')

const PRODUCTION = process.env.NODE_ENV === 'production'

module.exports = {
  context: __dirname,

  mode: PRODUCTION ? 'production' : 'development',

  entry: './src/index.ts',

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
              'F2',
              'F3',
              'F4',
              'F5',
              'F6',
              'F7',
              'F8',
              'F9',
              'A2',
              'A3',
              'A4',
              'A5',
              'A6',
              'A7',
              'A8',
              'A9'
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
          { loader: 'elm-hot-webpack-loader' },
          {
            loader: 'elm-webpack-loader',
            options: {
              debug: !PRODUCTION,
              optimize: PRODUCTION,
              verbose: true
            }
          }
        ]
      },
      {
        test: /\.ts$/,
        use: [
          {
            loader: 'ts-loader',
            options: {
              transpileOnly: true,
              experimentalWatchApi: true
            }
          }
        ]
      }
    ],

    noParse: /\.elm$/
  },

  plugins: [
    new HtmlPlugin({
      template: 'src/index.html'
    }),
    new TSCheckerPlugin()
  ],

  resolve: {
    extensions: ['.elm', '.js', '.ts']
  }
}
