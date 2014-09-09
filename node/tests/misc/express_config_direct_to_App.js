/*jslint node: true */
/*global describe, it, after, before */
"use strict";

var expect  = require('chai').expect, 
    app     = require('../../server');


describe('Direct access to Express Objects', function ()
{
    before(function() { app.server = app.listen(app.port);});
    after (function() { app.server.close();               });
    
      
});