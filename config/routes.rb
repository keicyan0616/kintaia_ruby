Rails.application.routes.draw do
  root 'static_pages#home'
  get  '/signup',   to: 'users#new'
  get    '/login',  to: 'sessions#new'
  post   '/login',  to: 'sessions#create'
  delete '/logout', to: 'sessions#destroy'
  
  # 上長勤怠申請関係
  get '/users/:id/superior_shinsei', to: 'users#kintai_shinsei', as: :shinsei_kintai
  #get '/users/:id/superior_shinsei', to: 'users#kintai_shinsei', as: :approval
  patch '/users/:id/soushin_kintai', to: 'users#soushin_kintai', as: :soushin_kintai
  patch '/users/:id/month_shinsei', to: 'users#month_shinsei', as: :month_shinsei
  get '/users/:id/:date/kintai_kakunin', to: 'users#kintai_kakunin'

  # 残業申請関係
  get '/users/:id/zangyo_shinsei_approval', to: 'users#zangyo_shinsei_approval', as: :shinsei_zangyo_approval  #残業申請承認画面表示(モーダル表示)
  get '/users/:id/attendances/:date/zangyou', to: 'attendances#zangyo_shinsei', as: :shinsei_zangyo  #残業申請画面表示(モーダル表示)
  patch 'users/:id/attendances/:date/zangyo_update', to: 'attendances#zangyo_update', as: :update_zangyo_attendances  #残業申請送信ボタン
  patch '/users/:id/soushin_zangyo_shinsei', to: 'users#soushin_zangyo_shinsei', as: :soushin_zangyo_shinsei
  
  # 基本情報編集
  get '/edit-basic-info/:id', to: 'users#edit_basic_info', as: :basic_info
  patch 'update-basic-info',  to: 'users#update_basic_info'
  
  # 勤怠編集画面
  get 'users/:id/editaprvls/:date/edit', to: 'editaprvls#edit', as: :edit_editaprvls
  #get 'users/:id/attendances/:date/edit', to: 'attendances#edit', as: :edit_attendances
  patch 'users/:id/editaprvls/:date/update', to: 'editaprvls#update', as: :update_editaprvls
  #patch 'users/:id/attendances/:date/update', to: 'attendances#update', as: :update_attendances
  get '/users/:id/editaprvl_shinsei', to: 'editaprvls#editaprvl_shinsei', as: :henko_shinsei_approval  #勤怠変更申請承認画面表示(モーダル表示)
  patch '/users/:id/soushin_henko_shinsei', to: 'editaprvls#soushin_henko_shinsei', as: :soushin_henko_shinsei
  get 'users/:id/editaprvls_log', to: 'editaprvls#kintai_log', as: :editaprvls_log
  get 'users/:id/editaprvls_part_log', to: 'editaprvls#kintai_part_log', as: :editaprvls_part_log
  post 'editaprvls/kintai_part_class', to: 'editaprvls#kintai_part_class', as: :kintai_part_class
  
  #出勤中社員一覧表示
  get '/attendances/shukkin_list', to: 'attendances#shukkin_list', as: :shukkin_list
  
  #拠点一覧表示
  get '/baseplaces/kyoten_list', to: 'baseplaces#kyoten_list', as: :kyoten_list
  get '/baseplaces/:id/kyoten_edit', to: 'baseplaces#kyoten_edit', as: :kyoten_edit
  delete '/basesplaces/:id/delete', to: 'baseplaces#destroy', as: :baseplace
  patch '/basesplaces/:id/update', to: 'baseplaces#update', as: :update_baseplace
  patch '/basesplaces/touroku', to: 'baseplaces#touroku', as: :touroku_baseplace
  
  # CSVファイルインポート
  #post '/import', to: 'users#import_csv', as: :import_csv
  # CSVファイルエクスポート
  get 'users/:id/attendances/:date/export', to: 'attendances#export', as: :export_csv
  
  resources :users do
    resources :attendances, only: :create
    collection { post :import }
  end
end