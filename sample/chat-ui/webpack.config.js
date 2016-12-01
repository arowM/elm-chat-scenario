const path              = require('path');
const webpack           = require('webpack');
const merge             = require('webpack-merge');
const HtmlWebpackPlugin = require('html-webpack-plugin');
const ExtractTextPlugin = require('extract-text-webpack-plugin');
const CopyWebpackPlugin = require('copy-webpack-plugin');

console.log('Starting webpack process...');

// Determine build env by npm command options
const TARGET_ENV = process.env.npm_lifecycle_event === 'build' ? 'production' : 'development';

// Common webpack config
const commonConfig = {

  output: {
    path: path.resolve(__dirname, 'dist/'),
    filename: '[name]-[hash].js',
  },

  entry: {
    index: [
      path.join( __dirname, 'src/index.js' )
    ],
  },

  resolve: {
    modulesDirectories: ['node_modules'],
    extensions: ['', '.js', '.elm'],
  },

  module: {
    loaders: [
      {
        test: /\.(eot|ttf|woff|woff2|svg)$/,
        loader: 'file-loader',
      },
      {
        test: /\.pug$/,
        loader: 'pug',
      },
      {
        test: /\.(jpg|jpeg|png)$/,
        loader: 'url'
      },
    ]
  },

  plugins: [
    new HtmlWebpackPlugin({
      chunks: ['index'],
      template: 'src/index.pug',
      inject:   'body',
      filename: 'index.html',
    }),
  ],

  postcss: () => [
    require('autoprefixer')({ browsers: ['last 2 versions'] }),
    require('postcss-flexbugs-fixes'),
  ],

}

// Settings for `npm start`
if (TARGET_ENV === 'development') {
  console.log('Serving locally...');

  const mapObjVals = (f, obj) =>
    Object.keys(obj).reduce((a, key) => {
      a[key] = f(obj[key]);
      return a;
    }, {});

  module.exports = merge(commonConfig, {

    entry: mapObjVals((v) =>
      ['webpack-dev-server/client?http://localhost:8080'],
      commonConfig.entry
    ),

    devServer: {
      contentBase: 'src',
      inline:   true,
      progress: true,
    },

    module: {
      loaders: [
        {
          test:    /\.elm$/,
          exclude: [/elm-stuff/, /node_modules/, /Stylesheets.elm/],
          loader:  'elm-hot!elm-webpack?verbose=true&warn=true',
        },
        {
          test: /\.(css|scss)$/,
          loaders: [
            'style',
            'css',
            'sass',
            'postcss',
          ]
        },
        {
          test: /src\/elm\/Stylesheets.elm$/,
          loaders: [
            'style',
            'css',
            'postcss',
            'elm-css-webpack',
          ]
        }
      ]
    }
  });
}

// Settings for `npm run build`.
if (TARGET_ENV === 'production') {
  console.log('Building for prod...');

  module.exports = merge(commonConfig, {

    module: {
      loaders: [
        {
          test:    /\.elm$/,
          exclude: [/elm-stuff/, /node_modules/, /Stylesheets.elm/],
          loader:  'elm-webpack',
        },
        {
          test: /\.(css|scss)$/,
          loader: ExtractTextPlugin.extract('style', [
            'css',
            'sass',
            'postcss',
          ])
        },
        {
          test: /src\/elm\/Stylesheets.elm$/,
          loader: ExtractTextPlugin.extract('style', [
            'css',
            'postcss',
            'elm-css-webpack',
          ])
        }
      ]
    },

    plugins: [
      new CopyWebpackPlugin([
        // {
        //   from: 'src/img/',
        //   to:   'img/',
        // },
        // {
        //   from: 'src/favicon.ico'
        // },
      ]),

      new webpack.optimize.OccurenceOrderPlugin(),

      // Extract CSS into a separate file
      new ExtractTextPlugin( './[hash].css', { allChunks: true } ),

      // Minify & mangle JS/CSS
      new webpack.optimize.UglifyJsPlugin({
          minimize:   true,
          compressor: { warnings: false }
          // mangle:  true
      }),
    ]
  });
}
