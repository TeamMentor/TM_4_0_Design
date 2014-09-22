module.exports = (app) ->
    
    app.get('/version'      , (req,res)  -> res.send(app.config.version) )   
