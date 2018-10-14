const MiniCssExtractPlugin = require('mini-css-extract-plugin');
const path = require('path');

module.exports = {
  entry: ['@babel/polyfill', './frontend/index.js'],

  stats: {
    children: false,
  },

  module: {
    rules: [
      {
        test: /\.(js|jsx)$/,
        exclude: /(node_modules)/,
        use: { loader: 'babel-loader' },
      },
      {
        test: /\.(css|scss)$/,
        use: [
          MiniCssExtractPlugin.loader,
          {
            loader: 'css-loader',
            options: {
              modules: true,
              localIdentName: '[path]__[name]__[local]__[hash:base64:5]',
            },
          },
          'postcss-loader',
        ],
      },
      {
        test: /\.png/,
        use: [
          {
            loader: 'file-loader',
            options: {
              name: '[path][name]-[hash:8].[ext]',
              publicPath: 'assets/',
            },
          },
        ],
      },
      {
        test: /\.svg/,
        use: {
          loader: 'react-svg-loader',
          options: {},
        },
      },
    ],
  },

  plugins: [
    new MiniCssExtractPlugin({
      filename: '[name].css',
      chunkFilename: '[id].css',
    }),
  ],

  devServer: {
    headers: {
      'Access-Control-Allow-Origin': '*',
    },
    stats: {
      children: false,
    },
  },

  output:
    process.env.NODE_ENV === 'production'
      ? {
          path: path.join(__dirname, '/priv/static/assets'),
          publicPath: '/assets',
        }
      : {
          path: path.resolve(__dirname, 'public'),
          publicPath: 'http://localhost:8080/assets',
        },

  resolve: {
    extensions: ['.js', '.jsx', '.json', '.css', '.scss'],
  },
};
