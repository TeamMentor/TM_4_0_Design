QA_TM_Design = require '../API/QA-TM_4_0_Design'

describe 'qa-workflow-login | ', ->
  page = QA_TM_Design.create(before, after)

  #afterEach (done)->
  #  testTitle = @.currentTest.fullTitle()
  #  page.screenshot testTitle, done

  #it 'Login page (take screenshot)', (done)->
  #  page.open '/user/login/returning-user-login.html', (html,$)->
  #    #$.title.log()
  #    $('.lge-container h3').text().assert_Is('Login')
  #
  #    done();



  it 'Login fail', (done)->
      #page.show ->
      page.open '/user/login/returning-user-login.html', (html)->
          code = "document.querySelector('#new-user-username').value='aaaa';
                  document.querySelector('#new-user-password').value='aaaa';
                  document.querySelector('#btn-login').click()"
          page.chrome.eval_Script code, ->
            page.wait_For_Complete (html, $) ->
                $('.alert').html().assert_Is('Login failed')
                done.invoke_In(0)

