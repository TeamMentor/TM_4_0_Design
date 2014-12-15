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

  page_About         : (callback) => @page.open '/about.html'             , callback
  page_Help          : (callback) => @page.open '/help/index.html'                , callback
  page_Home          : (callback) => @page.open '/index.html'                            , callback
  page_Features      : (callback) => @page.open '/features.html'               , callback
  page_Login         : (callback) => @page.open '/login.html'                  , callback
  page_Login_Fail    : (callback) -> @page.open '/login-Fail.html'             , callback
  page_Libraries     : (callback) => @page.open '/libraries'                                      , callback
  page_Main_Page     : (callback) => @page.open '/home/main-app-view.html'     , callback
  page_Pwd_Forgot    : (callback) => @page.open '/pwd-forgot.html'             , callback
  page_Pwd_Sent      : (callback) => @page.open '/pwd-sent.html'               , callback
  page_Sign_Up       : (callback) => @page.open '/sign-up.html'                , callback
  page_Sign_Up_Fail  : (callback) => @page.open '/sign-up-Fail.html'             , callback
  page_Sign_Up_OK    : (callback) => @page.open '/sign-up-OK.html'           , callback
  page_TermsAndCond  : (callback) => @page.open '/terms-and-conditions.html'                      , callback



  page_User_Help    : (callback        ) => @page.open '/help/index.html'                                , callback
  page_User_Library : (callback        ) => @page.open '/library/Uno'                                    , callback
  page_User_Logout  : (callback        ) => @page.open '/user/logout'                                    , callback
  page_User_Main    : (callback        ) => @page.open '/user/main.html'                        , callback
  page_User_Queries : (callback        ) => @page.open '/library/queries'                                , callback
  page_User_Graph   : (target, callback) => @page.open "/graph/#{target}"                                , callback


  session_Cookie  : (callback) =>
                      @page.chrome.cookies (cookies)->
                        for cookie in cookies
                          if cookie.name is "connect.sid"
                            callback(cookie)
                            return
                        callback(null)
  user_Sign_Up    : (username, password, email, callback) =>
                      @page_Sign_Up (html, $)=>
                        code = "document.querySelector('#new-user-username').value='#{username}';
                                document.querySelector('#new-user-password').value='#{password}';
                                document.querySelector('#new-user-confirm-password').value='#{password}';
                                document.querySelector('#new-user-email').value='#{email}';
                                document.querySelector('#btn-sign-up').click()"
                        @page.chrome.eval_Script code, =>
                          @page.wait_For_Complete (html, $)=>
                            callback()

module.exports = Jade_API