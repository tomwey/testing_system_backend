Rails.application.routes.draw do
  
  devise_for :admin_users, ActiveAdmin::Devise.config
  ActiveAdmin.routes(self)
  # 富文本上传路由
  mount RedactorRails::Engine => '/redactor_rails'
  
  get 'app/download' => 'home#download'
  get 'app/install'  => 'home#install'
  
  get 'credit_query' => 'home#credit_query'
  
  # 网页文档
  resources :pages, path: :p, only: [:show]
  
  # 获取二维码图片
  # /qrcode?text=http://www.baidu.com
  get 'qrcode' => 'home#qrcode', as: :qrcode
  
  get 'hls_key' => 'home#hls_key'
  
  # /redpack?id=3848484
  
  get 'promo/:id' => 'promo#poster'
  get 'channel/:id' => 'promo#channel'
  
  namespace :front, path: '' do 
    # 网页认证登录
    get    'login'    => 'sessions#new',       as: :login
    post   'login'    => 'sessions#create',    as: :do_login
    resources :profiles, only: [:new, :create]
    resources :salaries, only: [:new, :create]
    get '/salaries/apply_success' => 'salaries#apply_success', as: :apply_success
    # get    'redirect' => 'sessions#save_user', as: :redirect_uri
    # delete 'logout'   => 'sessions#destroy',   as: :logout
    # get 'app_auth' => 'sessions#app_auth'
    #
    # get 'redpack'       => 'redpacks#detail', as: :redpack
    #
    # redpack/result?id=3838939393
    # get 'redpack/result' => 'redpacks#result', as: :redpack_result
    #
    # get 'auth/redirect' => 'sessions#app_auth', as: :auth_redirect_uri
    #
    # post redpack/take?id=4848474&sign=3838392
    # post 'redpack/take' => 'redpacks#take', as: :redpack_take
    #
    # post 'pay/wx_notify' => 'home#wx_notify', as: :wx_notify
    
  end
  
  # 队列后台管理
  require 'sidekiq/web'
  authenticate :admin_user do
    mount Sidekiq::Web => 'sidekiq'
  end
  
  # # API 文档
  mount GrapeSwaggerRails::Engine => '/apidoc'
  # #
  # # API 路由
  mount API::Dispatch => '/api'
  
  match '*path', to: 'home#error_404', via: :all
end
