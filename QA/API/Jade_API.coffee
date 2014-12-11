class Jade_API
  constructor: (page)->
    @page     = page
    @QA_Users = [{ name:'user', pwd: 'a'}]

  clear_Session: (callback)->
                  @page.chrome.delete_Cookie 'connect.sid', 'http://localhost/', callback

  login          : (username, password, callback)=>
                    @page_Login =>
                      code = "document.querySelector('#new-user-username').value='#{username}';
                              document.querySelector('#new-user-password').value='#{password}';
                              document.querySelector('#btn-login').click()"
                      @page.chrome.eval_Script code, =>
                        @page.wait_For_Complete callback

  login_As_QA   : (callback) =>
                    user = @QA_Users.first()
                    @login user.name, user.pwd, callback

  session_Cookie  : (callback) =>
                    @page.chrome.cookies (cookies)->
                      for cookie in cookies
                        if cookie.name is "connect.sid"
                          callback(cookie)
                          return
                      callback(null)

  page_About      : (callback) => @page.open '/landing-pages/about.html'                       , callback
  page_Help       : (callback) => @page.open '/help/index.html'                                , callback
  page_Home       : (callback) => @page.open '/'                                               , callback
  page_Features   : (callback) => @page.open '/landing-pages/features.html'                    , callback
  page_Login      : (callback) => @page.open '/user/login/returning-user-login.html'           , callback
  page_Login_Fail : (callback) -> @page.open '/user/login/returning-user-validation.html'      , callback
  page_Libraries  : (callback) => @page.open '/libraries'                                      , callback
  page_Main_Page  : (callback) => @page.open '/home/main-app-view.html'                        , callback
  page_Pwd_Forgot : (callback) => @page.open '/user/login/returning-user-forgot-password.html' , callback
  page_Pwd_Sent   : (callback) => @page.open '/user/login/forgot-password-completed.html'      , callback



module.exports = Jade_API