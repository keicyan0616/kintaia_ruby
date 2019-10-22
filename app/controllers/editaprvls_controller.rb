class EditaprvlsController < ApplicationController
  #before_action :correct_or_admin_user,   only: [:edit]

#   def create
#     @user = User.find(params[:user_id])
#     @attendance = @user.attendances.find_by(worked_on: Date.today)
#     if @attendance.started_at.nil?
#       @attendance.update_attributes(started_at: current_time)
#       flash[:info] = 'おはようございます。'
#     elsif @attendance.finished_at.nil?
#       @attendance.update_attributes(finished_at: current_time)
#       flash[:info] = 'おつかれさまでした。'
#     else
#       flash[:danger] = 'トラブルがあり、登録出来ませんでした。'
#     end
#     redirect_to @user
#   end
  
   # ### 1．勤怠編集関係 ######
   # --- 勤怠編集画面 表示 -----
   def edit
     logger.debug "ここを通ったよ(024)"
     
     @user = User.find(params[:id])
     @first_day = first_day(params[:date])
     #@first_day = first_day(params[:first_day])
     @last_day = @first_day.end_of_month
     
     (@first_day..@last_day).each do |day|
       unless @user.editaprvls.any? {|editaprvl| editaprvl.change_kintai_req_on == day}
         record = @user.editaprvls.build(change_kintai_req_on: day)
         #record.user_id = nil
         #record.change_target_person_id = @user.id
         record.save
       end
     end
     @dates = user_editaprvls_month_date
   end
   
   # --- 勤怠編集画面 更新送信 -----
   def update
     @user = User.find(params[:id])
     #if editaprvls_invalid?
       logger.debug "ここを通ったよ(027)"
       editaprvls_params.each do |id, item|
           
#翌日フラグを見ながら書き込み
#           @finished_plan_at = Time.parse(@slct_date + " " + @finished_plan_time.strftime("%H:%M") + " +0900")
#           #残業時間申請日時の翌日設定
#           if @yokujitsu_kakunin_check == "1" then
#             #@finished_plan_at = Time.parse(attendance.worked_on.tomorrow.strftime("%Y-%m-%d") + " " + attendance.finished_plan_at.strftime("%H:%M") + " +0900")
#             @finished_plan_at = @finished_plan_at.tomorrow
#           end

#指示確認㊞欄に入力があれば書き込み
         editaprvl = Editaprvl.find(id)
         editaprvl.update_attributes(item)
         #editaprvl.user_id = params[:"shonin#{id}"]
         #@id = id
         @shonin_id = params[:"shonin#{id}"]
         editaprvl.user_id = params[:id]
         editaprvl.change_target_person_id = @shonin_id
         if @shonin_id != ""
           editaprvl.change_aprvl_status = "申請中"
         end
         editaprvl.save
       end
       flash[:success] = "勤怠情報を更新しました。" #{@shonin_id}"
       redirect_to user_path(@user, params:{first_day: params[:date]})
#     else
#       flash[:danger] = "不正な時間入力がありました、再入力してください。"
#       redirect_to edit_attendances_path(@user, params[:date])
     #end
   end

  # ### 2．勤怠編集(承認者側)関係 #####-------------------------------------------------------------------------   
  # 2-1.画面表示(勤怠編集承認モーダル画面)
  def editaprvl_shinsei
    logger.debug "ここを通ったよ(025)"
    @user = User.find(params[:id])
    #@editaprvls = Editaprvl.where(user_id: params[:id]).where.not(change_aprvl_status: "承認").order(change_target_person_id: :asc).order(change_kintai_req_on: :asc)
    @editaprvls = Editaprvl.where(change_target_person_id: params[:id]).where.not(change_aprvl_status: "承認").where.not(change_aprvl_status: nil).order(user_id: :asc).order(change_kintai_req_on: :asc)
  end

  # 2-2.変更申請承認(勤怠編集申請承認モーダル画面)
  def soushin_henko_shinsei
    logger.debug "ここを通ったよ(026)"
    @user = User.find(params[:id])
    @editaprvls = Editaprvl.where(change_target_person_id: params[:id]).where.not(change_aprvl_status: "承認").where.not(change_aprvl_status: nil).order(user_id: :asc).order(change_kintai_req_on: :asc)
    
    @editaprvls.each do |edit_app_data|
      @app_tmp = edit_app_data.id
      @shiji_kakunin_id = params[:"edit_shiji_kakunin#{@app_tmp.to_s}"]
      if @shiji_kakunin_id == "1"
        if params[:"note#{@app_tmp.to_s}"] == ""
          edit_app_data.delete
        else
          edit_app_data.change_aprvl_status = params[:"note#{@app_tmp.to_s}"]
          edit_app_data.save
        end
      end
    end
    #@aps = params[:note4]
    #@aps = params[:"note#{@app_tmp.to_s}"]
    #flash[:success] = @shiji_kakunin_id
    flash[:success] = "変更を送信しました。"
    redirect_to @user 
  end
   
  def kintai_log
    logger.debug "ここを通ったよ(027)"
    @user = User.find(params[:id])
    #@log_data = Editaprvl.where(user_id: params[:id]).where(change_kintai_req_on: "2019-09-01".."2019-09-30")
    @year_value = "999"
  end
  
  def kintai_part_log
    logger.debug "ここを通ったよ(028)"
    #@user = User.find(params[:id])
    #@log_data = Editaprvl.where(user_id: params[:id]).where(change_kintai_req_on: "2019-10-01".."2019-10-31")
    #@year_value = "999"
  end

  def kintai_part_class
    logger.debug "ここを通ったよ(029)"
    #@year_value = "333"
    @year_value = params[:year_value]
    @log_data = Editaprvl.where(user_id: params[:id]).where(change_kintai_req_on: "2019-09-01".."2019-09-30")
  end

  # def call_ajax
  #   # 選択肢のデータを取得
  #   item_list = {
  #     '1' => [['x1', '1'], ['x2', '2'], ['x3', '3']],
  #     '2' => [['y1', '4'], ['y2', '5'], ['y3', '6']],
  #     '3' => [['z1', '7'], ['z2', '8'], ['z3', '9']]
  #   }
  #   items = item_list[params['id']]
  #   # Javascriptの呼び出し
  #   render :update do |page|
  #     #選択肢を削除
  #     page.call 'clear_item'
  #     #選択肢を追加
  #     items.each { |item| page.call 'update_menu', item[0], item[1] }
  #   end
  # end

  # def asfdfawefta
  #   # select_tagのデフォルト値に使用
  #   class_first = ClassName.find(1)
  #   # select_tagから現在選択されているクラスのid取得
  #   # 未選択時はデフォルトのclass_first
  #   @class_id = params[class_id]  || class_first
  #   # クラスに属する生徒を取得
  #   @students = Student.where(class_id: @class_id)
  # end

#   # ### 2．残業申請(申請者側)関係 ######
#   # 2-1．モーダル表示（残業申請モーダル画面）
#   def zangyo_shinsei
#     logger.debug "ここを通ったよ(010)"
#     @user = User.find(params[:id])
#     @slct_day = Date.strptime(params[:date]) #.to_s(:date)
#     #@attendance = @user.attendances.find_by(worked_on: params[:date]) #もう不要かも

#     #更新データの取得(モーダル画面とDBのリンク付け)
#     @zangyoaprvl = Zangyoaprvl.find_by(zangyo_aprvl_req_on: params[:date], zangyo_target_person_id: params[:id])
#     unless @zangyoaprvl.present? 
#       #更新データがない場合、一旦、承認者を自分のIDでデータ作成(モーダル画面表示するため)
#       @zangyoaprvl = Zangyoaprvl.new(user_id: params[:id], zangyo_aprvl_req_on: params[:date], zangyo_target_person_id: params[:id], yuko_flag: 0)
#       @zangyoaprvl.save
#     end

#     @shonin_id_show = 0
#     if @zangyoaprvl.present? && @zangyoaprvl.yuko_flag == 1
#       @shonin_id_show = @zangyoaprvl.user_id
#     end
#     #@first_day = first_day(params[:date])
#     #@last_day = @first_day.end_of_month
#     #@attend_date = Attendance.find(1)
#     #@dates = user_attendances_month_date
#   end

#   # 2-2．変更送信（残業申請モーダル画面）
#   def zangyo_update
#     logger.debug "ここを通ったよ(011)"

#     #各種値を取得
#     @user = User.find(params[:id])                                      #残業申請者ID
#     @slct_date = params[:date]                                          #残業申請日
#     @yokujitsu_kakunin_check = params[:"yokujitsu_kakunin"]             #翌日(チェック)
#     @shonin_id = params[:user][:name]                                   #残業承認者ID
#     #@attendance = @user.attendances.find_by(worked_on: params[:date])
#     #if attendances_invalid?

#     #残業申請日の申請済みデータの取得(有無チェック用)
#     @zangyo_apr_count = Zangyoaprvl.where(zangyo_aprvl_req_on: @slct_date).where(zangyo_target_person_id: @user.id).where(zangyo_aprvl_status: "申請中").where(yuko_flag: 1).count
#     #@zangyo_apr_count = Zangyoaprvl.where(zangyo_aprvl_req_on: @slct_date).where(zangyo_target_person_id: @user.id).where.not(zangyo_finished_at: nil).where.not(zangyo_aprvl_status: "承認").where(yuko_flag: 1).count

#     #残業申請データの登録
#     if @zangyo_apr_count > 0
#       flash[:danger] = "既に申請済みです。"
#     else
#       #承認済みデータの無効化
#       #@zangyo_apr_finished = Zangyoaprvl.where(zangyo_aprvl_req_on: @slct_date).where(zangyo_target_person_id: @user.id).where.not(zangyo_finished_at: nil).where(zangyo_aprvl_status: "承認").where(yuko_flag: 1).count

#       zangyoaprvl_params.each do |id, item|
#         @gyomu_memo_tmp = params[:zangyoaprvls][id][:zangyo_note]                 #業務処理内容
#         @finished_plan_time_tmp = params[:zangyoaprvls][id][:zangyo_finished_at]  #終了予定時間
#         #入力チェック
#         if @finished_plan_time_tmp == ""
#           flash[:danger] = "「終了予定時間」を入力してください。"
#         elsif @gyomu_memo_tmp == "" 
#           flash[:danger] = "「業務処理内容」を入力してください。"
#         elsif @shonin_id == ""
#           flash[:danger] = "「指示者確認㊞」を選択してください。"
#         else
#           #対象データの取得と更新
#           zangyoaprvl = Zangyoaprvl.find(id)
#           zangyoaprvl.update_attributes(item)
#           @gyomu_memo = zangyoaprvl.zangyo_note                              #業務処理内容
#           @finished_plan_time = zangyoaprvl.zangyo_finished_at               #終了予定時間

#           @finished_plan_at = Time.parse(@slct_date + " " + @finished_plan_time.strftime("%H:%M") + " +0900")
#           #残業時間申請日時の翌日設定
#           if @yokujitsu_kakunin_check == "1" then
#             #@finished_plan_at = Time.parse(attendance.worked_on.tomorrow.strftime("%Y-%m-%d") + " " + attendance.finished_plan_at.strftime("%H:%M") + " +0900")
#             @finished_plan_at = @finished_plan_at.tomorrow
#           end
#           #@calc_work_datetime = Time.parse(zangyo_data.zangyo_aprvl_req_on.strftime("%Y-%m-%d") + " " + @target_user.work_end_time.strftime("%H:%M") + " +0900")

#           #@zangyo_apr = Zangyoaprvl.new(user_id: @shonin_id, zangyo_aprvl_req_on: @slct_date, zangyo_aprvl_status: "申請中", zangyo_finished_at: @finished_plan_at.to_s, 
#                                         #zangyo_note: @gyomu_memo.to_s, zangyo_target_person_id: @user.id, yuko_flag: 1)
#           #@zangyo_apr.save 
#           zangyoaprvl.user_id = @shonin_id
#           zangyoaprvl.zangyo_aprvl_req_on = @slct_date
#           zangyoaprvl.zangyo_aprvl_status = "申請中"
#           zangyoaprvl.zangyo_finished_at = @finished_plan_at.to_s
#           zangyoaprvl.zangyo_note = @gyomu_memo.to_s
#           zangyoaprvl.zangyo_target_person_id = @user.id
#           zangyoaprvl.yuko_flag = 1
#           zangyoaprvl.save
#           flash[:success] = "残業申請を送信しました。"
#         end
#       end
#     end
#     ############################################
#     #zangyo_app_data.zangyo_aprvl_status = params[:"note#{@app_tmp.to_s}"]
#     #zangyo_app_data.save

#     #redirect_to user_path(@user, params:{first_day: params[:date]})
#     #else
#       #flash[:danger] = "不正な時間入力がありました、再入力してください。"
#       #redirect_to edit_attendances_path(@user, params[:date])
#     #end
#     #end

#     # 勤怠画面(トップ画面)を再表示
#     @first_day_l = Date.strptime(params[:date]).beginning_of_month
#     redirect_to user_path(@user, params:{first_day: @first_day_l})
#   end

#   # ### 3．出勤中社員一覧関係 ######
#   def shukkin_list
#     @users = User.all
#     @shukkin_users = []

#     @users.each do |user| 
#       if @attendances = user.attendances.find_by(worked_on: Date.today, finished_at: nil)
#         @shukkin_users.push(user) if @attendances.started_at.present?
#         #debugger
#       end
#     end
#   end

#   # ### CSV出力ボタン押下時 #####
#   def export
#     logger.debug "ここを通ったよ(015)"
#     @user = User.find(params[:id])
#     @first_day = first_day(params[:date])
#     @last_day = @first_day.end_of_month
#     @attendances = @user.attendances.where("worked_on >= ?", @first_day).where("worked_on <= ?", @last_day)

#     respond_to do |format|
#       format.csv do
#         send_data render_to_string, filename: "hoge.csv", type: :csv
#       end
#     end
#   end

private
  def editaprvls_params
    params.permit(editaprvls: [:change_kintai_req_on, :change_started_at, :change_finished_at, :note, :user_id])[:editaprvls]
  end
#     def attendances_zangyo_params
#       #params.permit(attendances: [:finished_plan_at, :gyomu_memo])[:attendances]
#       params.permit(attendances: [:finished_at])[:attendances]
#     end

#     def zangyoaprvl_params
#       params.permit(zangyoaprvls: [:zangyo_finished_at, :zangyo_note])[:zangyoaprvls]
#     end

#     # 正しいユーザー、または、管理者ユーザーかどうか確認
#     def correct_or_admin_user
#       @user = User.find(params[:id])
#       redirect_to(root_url) unless current_user?(@user) or current_user.admin?
#     end
end