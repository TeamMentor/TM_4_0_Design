Jade_Controller = require('../../controllers/Jade-Controller')

describe 'controllers | Jade-Controller.test.js |', ()->

 it 'renderMixin', (done)->
    req    = { params: { file : 'images' , mixin:'image-securityinnovation-logo' }}
    res    =
      send: (html)->
        html.assert_Contains('<a href="http://www.securityinnovation.com/" target="_blank">')
        done()

    using new Jade_Controller(req, res), ->
      @.renderMixin()