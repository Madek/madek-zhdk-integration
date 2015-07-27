Rails.application.routes.draw do

  get '/login',
    to:  "madek_zhdk_integration/authentication#login",
    as: 'zhdk_login_form'

  get '/authenticator/zhdk/login_successful/:id',
    to: "madek_zhdk_integration/authentication#login_successful",
    as: 'zhdk_login_callback'

end
