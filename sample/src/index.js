'use strict';

// require('./styles/main.scss');

// Inject bundled Elm app into div#main
var Elm = require('Sample');
var app = Elm.Main.embed(document.getElementById('main'));
