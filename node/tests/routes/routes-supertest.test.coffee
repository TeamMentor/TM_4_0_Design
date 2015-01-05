supertest = require('supertest')
app       = require('../../server')

describe 'routes | routes-supertest.test |',  ()->

    app.config.enable_Jade_Cache = true;

    describe 'debug methods', ()->
        it '/ping', (done)->
            supertest(app).get('/ping')
                          .expect(200, 'pong..',done);

        it '/session', (done)->
          expectedSessionValue = '{"cookie":{"originalMaxAge":null,"expires":null,"httpOnly":true,"path":"/"}}';
      
          supertest(app).get('/session')
                        .expect(200, expectedSessionValue,done);

