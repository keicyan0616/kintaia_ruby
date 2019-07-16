Rails.application.routes.draw do
  root 'static_pages#home'
  get  '/signup',   to: 'users#new'
  get    '/login',  to: 'sessions#new'
  post   '/login',  to: 'sessions#create'
  delete '/logout', to: 'sessions#destroy'
  
  # 上長勤怠申請関係
  get '/users/:id/senior_shinsei', to: 'users#kintai_shinsei', as: :shinsei_kintai
  get '/users/:id/senior_shinsei', to: 'users#kintai_shinsei', as: :approval
  patch '/users/:id/soushin_kintai', to: 'users#soushin_kintai', as: :soushin_kintai
  get '/users/:id/:date/kintai_kakunin', to: 'users#kintai_kakunin'
  
  # 基本情報編集
  get '/edit-basic-info/:id', to: 'users#edit_basic_info', as: :basic_info
  patch 'update-basic-info',  to: 'users#update_basic_info'
  get 'users/:id/attendances/:date/edit', to: 'attendances#edit', as: :edit_attendances
  patch 'users/:id/attendances/:date/update', to: 'attendances#update', as: :update_attendances
  resources :users do
    resources :attendances, only: :create
  end
end