Rails.application.routes.draw do

  get '/login', :to => "madek_zhdk_integration/authentication#login"
  get '/authenticator/zhdk/login_successful/:id', :to => "madek_zhdk_integration/authentication#login_successful"

end
