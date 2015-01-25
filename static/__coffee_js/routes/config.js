(function() {
  module.exports = function(app) {
    app.get('/version', function(req, res) {
      return res.send(app.config.version);
    });
    return app.get('/config', function(req, res) {
      return res.send(app.config);
    });
  };

}).call(this);
