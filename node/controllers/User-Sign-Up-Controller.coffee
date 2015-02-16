
class User_Sign_Up_Controller

  userSignUp: ()=>
    userViewModel =
                    {
                        username        : @.req.body.username,
                        password        : @.req.body.password,
                        confirmpassword : @.req.body['confirm-password']
                        email           : @.req.body.email
                        errorMessage    :''
                    }
    if (@.req.body.password != @.req.body['confirm-password'])
        userViewModel.errorMessage='Passwords don\'t match'
        @res.render(signUp_fail,viewModel: userViewModel)
        return
    newUser =
              {
                  username : @.req.body.username,
                  password : @.req.body.password,
                  email    : @.req.body.email
              }
    options = {
                method: 'post',
                body: {newUser: newUser},
                json: true,
                url: @.webServices + '/CreateUser_Response'
              };

    request options, (error, response, body)=>
      if (error and error.code=="ENOTFOUND")
        @.res.send('could not connect with TM Uno server')
        return

      if (response.body!=null && response.statusCode == 200)
        signUpResponse = response.body.d
        message= ''

        if (signUpResponse.Signup_Status!=0)
          if (signUpResponse.Validation_Results!=null && signUpResponse.Validation_Results.not_Empty())
              message = signUpResponse.Validation_Results.first().Message
          else
              message = signUpResponse.Simple_Error_Message
          userViewModel.errorMessage=message
          @res.render(signUp_fail, {viewModel:userViewModel})
        else
          @res.redirect('/guest/sign-up-OK.html')

module.exports = User_Sign_Up_Controller