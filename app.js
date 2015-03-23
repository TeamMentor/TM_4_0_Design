/*jslint node: true */
"use strict";
require('coffee-script/register');                      // enable coffee-script support
require('fluentnode')                                   // register fluentnode files

var Express_Service = require('./src/services/Express-Service')
new Express_Service()
      .setup()
      .start()
