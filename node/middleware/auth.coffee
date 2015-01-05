
Jade_Service = require('../services/Jade-Service')
loginEnabled = true;

checkAuth = (req, res, next, config)->
  if (loginEnabled && req && req.session &&!req.session.username)
    res.status(403)
        .send(new Jade_Service(config).renderJadeFile('/source/jade/guest/login-required.jade'))
  else
    next()


mappedAuth = (req)->
  data = {};
  if(req && req.session)
      data =  {
                  username  : req.session.username,
                  loggedIn  : (req.session.username != undefined)
              }
  return data


module.exports = { 
                    checkAuth : checkAuth,
                    mappedAuth : mappedAuth
                 };