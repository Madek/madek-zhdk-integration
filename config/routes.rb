Rails.application.routes.draw do

  get '/login/zhdk',
      to:  'madek_zhdk_integration/authentication#login',
      as: 'zhdk_login_form'

  get '/login/zhdk/login_successful/:id',
      to: 'madek_zhdk_integration/authentication#login_successful',
      as: 'zhdk_login_callback'

end
