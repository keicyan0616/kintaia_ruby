Rails.application.routes.draw do
  root 'static_pages#home'
  get  '/signup',   to: 'users#new'
  get    '/login',  to: 'sessions#new'
  post   '/login',  to: 'sessions#create'
  delete '/logout', to: 'sessions#destroy'
  
  # 上長勤怠申請関係
  get '/users/:id/senior_shinsei', to: 'users#kintai_shinsei', as: :shinsei_kintai
  #get '/users/:id/senior_shinsei', to: 'users#kintai_shinsei', as: :approval
  patch '/users/:id/soushin_kintai', to: 'users#soushin_kintai', as: :soushin_kintai
  patch '/users/:id/month_shinsei', to: 'users#month_shinsei', as: :month_shinsei
  get '/users/:id/:date/kintai_kakunin', to: 'users#kintai_kakunin'

  # 残業申請関係
  get '/users/:id/zangyo_shinsei_approval', to: 'users#zangyo_shinsei_approval', as: :shinsei_zangyo_approval  #残業申請承認画面表示
  get '/users/:id/attendances/:date/zangyou', to: 'attendances#zangyo_shinsei', as: :shinsei_zangyo  #残業申請画面表示
  patch 'users/:id/attendances/:date/zangyo_update', to: 'attendances#zangyo_update', as: :update_zangyo_attendances  #残業申請送信ボタン
  patch '/users/:id/soushin_zangyo_shinsei', to: 'users#soushin_zangyo_shinsei', as: :soushin_zangyo_shinsei
  
  # 基本情報編集
  get '/edit-basic-info/:id', to: 'users#edit_basic_info', as: :basic_info
  patch 'update-basic-info',  to: 'users#update_basic_info'
  get 'users/:id/attendances/:date/edit', to: 'attendances#edit', as: :edit_attendances
  patch 'users/:id/attendances/:date/update', to: 'attendances#update', as: :update_attendances
  resources :users do
    resources :attendances, only: :create
  end
end