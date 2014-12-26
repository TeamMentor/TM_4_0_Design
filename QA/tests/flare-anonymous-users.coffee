require 'fluentnode'
require('../node_modules/nwr/src/extra_fluentnode')

QA_TM_Design = require '../API/QA-TM_4_0_Design'

describe 'flare-anonymous-users', ->
  page  = QA_TM_Design.create(before, after);
  flare = page.flare_API;

  before (done)-> flare.clear_Session done                                   # ensure we are anonymous

  @timeout(4000)

  afterEach (done)->
#    page.html (html,$)->
#      $('title').text().assert_Is('TEAM Mentor 4.0 (Html version)')         # confirm that all pages have the same title
#      check_Top_Right_Navigation_Bar($)
      done()

  it 'All',(done)->
    flare.page_All (html,$)->
      #console.log html
      done()

  it '/help',(done)->
    page.open '/flare/help/index', (html,$)->
      #console.log html
      done()