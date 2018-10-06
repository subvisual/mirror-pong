const MiniCssExtractPlugin = require('mini-css-extract-plugin');
const path = require('path');

module.exports = {
  entry: './frontend/index.js',

  stats: {
    children: false,
  },

  module: {
    rules: [
      {
        test: /\.svg/,
        use: {
          loader: 'react-svg-loader',
          options: {},
        },
      },
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
    ],
  },

  plugins: [
    new MiniCssExtractPlugin({
      filename: '[name].css',
      chunkFilename: '[id].css',
    }),
  ],

  output: {
    path: path.join(__dirname, '/priv/static/assets'),
    publicPath: '/assets',
  },

  resolve: {
    extensions: ['.js', '.jsx', '.json', '.css', '.scss'],
  },
};
