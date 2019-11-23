class EditaprvlsController < ApplicationController
  before_action :logged_in_user, only: [:edit, :update]
  before_action :correct_user,   only: [:edit, :update, :editaprvl_shinsei, :soushin_henko_shinsei, :kintai_log]
  before_action :not_admin_user, only: [:edit]

  # ### 1．勤怠編集関係 ######
  # --- 勤怠編集画面 表示 -----
  def edit
    #logger.debug "ここを通ったよ(024)"
    @user = User.find(params[:id])
    @first_day = first_day(params[:date])
    @last_day = @first_day.end_of_month
     
    (@first_day..@last_day).each do |day|
      unless @user.editaprvls.any? {|editaprvl| editaprvl.change_kintai_req_on == day}
        record = @user.editaprvls.build(change_kintai_req_on: day)
        record.save
      end
    end
    @dates = user_editaprvls_month_date
  end
   
  # --- 勤怠編集画面 更新送信 -----
  def update
    
    @user = User.find(params[:id])
    #logger.debug "ここを通ったよ(027)"
    @error_hnt = "OK"
    @edit_kintai_req_on = ""
    
    editaprvls_params.each do |id, item|
      editaprvl = Editaprvl.find(id)
       
      @yokujitsu_kakunin_check = ""
      @edit_started_time_4i = ""
      @edit_started_time_5i = ""
      @edit_started_time = ""
      @edit_finished_time_4i = ""
      @edit_finished_time_5i = ""
      @edit_finished_time = ""
      @note = ""

      @yokujitsu_kakunin_check = params[:"yokujitsu_kakunin#{id}"]                  #翌日(チェック)
      @edit_started_time_4i = params[:editaprvls][id][:"change_started_at(4i)"]     #変更出勤時間(時)
      @edit_started_time_5i = params[:editaprvls][id][:"change_started_at(5i)"]     #変更出勤時間(分)
      @edit_finished_time_4i = params[:editaprvls][id][:"change_finished_at(4i)"]   #変更退社時間(時)
      @edit_finished_time_5i = params[:editaprvls][id][:"change_finished_at(5i)"]   #変更退社時間(分)
      @note = params[:editaprvls][id][:"note"]                                      #備考

      #指示確認㊞欄に入力があれば書き込み
      @shonin_id = params[:"shonin#{id}"]
      editaprvl.user_id = params[:id]
      editaprvl.change_target_person_id = @shonin_id

      ### 入力チェック ###
      if @shonin_id != "" and (@edit_started_time_4i == "" or @edit_started_time_5i == "" or @edit_started_time_4i == nil or @edit_started_time_5i == nil) \
          and editaprvl.change_kintai_req_on < Date.tomorrow then
        @edit_kintai_req_on = editaprvl.change_kintai_req_on.strftime("%Y-%m-%d") if @edit_kintai_req_on == ""
        @error_hnt = "START_NG"
      elsif @shonin_id != "" and (@edit_finished_time_4i == "" or @edit_finished_time_5i == "" or @edit_finished_time_4i == nil or @edit_finished_time_5i == nil) \
          and editaprvl.change_kintai_req_on < Date.tomorrow then
        @edit_kintai_req_on = editaprvl.change_kintai_req_on.strftime("%Y-%m-%d") if @edit_kintai_req_on == ""
        @error_hnt = "FINISH_NG"
      elsif @shonin_id == "" and editaprvl.approval_at != nil
        @edit_kintai_req_on = editaprvl.change_kintai_req_on.strftime("%Y-%m-%d") if @edit_kintai_req_on == ""
        @error_hnt = "SHONIN_SELECT_NG"
      end

      if @edit_started_time_4i != "" and @edit_started_time_5i != "" and @edit_started_time_4i != nil and @edit_started_time_5i != nil then
        @edit_started_time = Time.parse(editaprvl.change_kintai_req_on.strftime("%Y-%m-%d") + " " + @edit_started_time_4i.to_s + ":" + @edit_started_time_5i.to_s + " +0900")    #変更出勤時間
      end
      if @edit_finished_time_4i != "" and @edit_finished_time_5i != "" and @edit_finished_time_4i != nil and @edit_finished_time_5i != nil then
        @edit_finished_time = Time.parse(editaprvl.change_kintai_req_on.strftime("%Y-%m-%d") + " " + @edit_finished_time_4i.to_s + ":" + @edit_finished_time_5i.to_s + " +0900") #変更退社時間
      end

      #退社時間変更申請日時の翌日設定
      #翌日フラグを見ながら書き込み(各日での翌日フラグを取得して、翌日日時取得後、退社日時を上書き)
      if @yokujitsu_kakunin_check == "1" then
        @edit_finished_time = Time.parse(editaprvl.change_kintai_req_on.tomorrow.strftime("%Y-%m-%d") + " " + @edit_finished_time_4i.to_s + ":" + @edit_finished_time_5i.to_s + " +0900")
      end

      #出社、退社時間の入力チェック
      if @shonin_id != "" and @edit_started_time.present? and @edit_finished_time.present?
        if @edit_started_time > @edit_finished_time
          @edit_kintai_req_on = editaprvl.change_kintai_req_on.strftime("%Y-%m-%d") if @edit_kintai_req_on == ""
          @error_hnt = "ZENGO_NG"
        end
      end

      if @shonin_id != "" and editaprvl.change_kintai_req_on < Date.tomorrow
        editaprvl.change_aprvl_status = "申請中"
      else
        editaprvl.change_aprvl_status = ""
      end
      editaprvl.change_started_at = @edit_started_time
      editaprvl.change_finished_at = @edit_finished_time
      editaprvl.note = @note
      if @error_hnt == "OK"
        editaprvl.save
      end
    end
      
    if @error_hnt == "OK"
      flash[:success] = "勤怠情報を更新しました。"
      redirect_to user_path(@user, params:{first_day: params[:date]})
    else
      if @error_hnt == "START_NG"
        flash[:danger] = "「#{@edit_kintai_req_on}」の出社時間を入力してください。"
      elsif @error_hnt == "FINISH_NG"
        flash[:danger] = "「#{@edit_kintai_req_on}」の退社時間を入力してください。"
      elsif @error_hnt == "ZENGO_NG"
        flash[:danger] = "「#{@edit_kintai_req_on}」の退社が出社より早い時間です。"
      elsif @error_hnt == "SHONIN_SELECT_NG"
        flash[:danger] = "「#{@edit_kintai_req_on}」の指示確認㊞欄を選択してください。"
      else
        flash[:danger] = "不正な時間入力がありました、再入力してください。"
      end
      @first_day = first_day(params[:date])
      redirect_to edit_editaprvls_path(@user, @first_day)
    end
  end

  # ### 2．勤怠編集(承認者側)関係 #####-------------------------------------------------------------------------   
  # 2-1.画面表示(勤怠編集承認モーダル画面)
  def editaprvl_shinsei
    #logger.debug "ここを通ったよ(025)"
    @user = User.find(params[:id])
    @editaprvls = Editaprvl.where(change_target_person_id: params[:id]).where.not(change_aprvl_status: "承認").where.not(change_aprvl_status: "否認").where.not(change_aprvl_status: nil)\
                  .order(user_id: :asc).order(change_kintai_req_on: :asc)
  end

  # 2-2.変更申請承認(勤怠編集申請承認モーダル画面)
  def soushin_henko_shinsei
    #logger.debug "ここを通ったよ(026)"
    @user = User.find(params[:id])
    @editaprvls = Editaprvl.where(change_target_person_id: params[:id]).where.not(change_aprvl_status: "承認").where.not(change_aprvl_status: "否認").where.not(change_aprvl_status: nil)\
                  .order(user_id: :asc).order(change_kintai_req_on: :asc)
    
    @editaprvls.each do |edit_app_data|
      @app_tmp = edit_app_data.id
      @shiji_kakunin_id = params[:"edit_shiji_kakunin#{@app_tmp.to_s}"]
      if @shiji_kakunin_id == "1"
        if params[:"note#{@app_tmp.to_s}"] == ""
          edit_app_data.delete
        else
          if params[:"note#{@app_tmp.to_s}"] == "承認"
            @attend_data = ""
            @attend_data = Attendance.find_by(user_id: edit_app_data.user_id, worked_on: edit_app_data.change_kintai_req_on)
            ### ここで変更前の出勤、退勤時間が入ってなかったらAttendanceテーブルから取得して、Editaprvlテーブルに書き込む ###
            if @attend_data.present?
              edit_app_data.change_first_started_at = @attend_data.started_at if edit_app_data.approval_at == nil
              edit_app_data.change_first_finished_at = @attend_data.finished_at if edit_app_data.approval_at == nil
              @attend_data.started_at = edit_app_data.change_started_at
              @attend_data.finished_at = edit_app_data.change_finished_at
              @attend_data.note = edit_app_data.note
              @attend_data.save
            end
            edit_app_data.approval_at = Time.now
          end
          edit_app_data.change_aprvl_status = params[:"note#{@app_tmp.to_s}"]
          edit_app_data.save
        end
      end
    end
    flash[:success] = "変更を送信しました。"
    redirect_to @user 
  end

  # ### 3．勤怠ログ関係 #####-------------------------------------------------------------------------   
  # 3-1.画面表示(勤怠ログ画面)
  def kintai_log
    #logger.debug "ここを通ったよ(027)"
    @user = User.find(params[:id])
    @id = params[:id]
    @year_value = params[:year_search]
    @log_data = Editaprvl.where(user_id: params[:id]).where(change_kintai_req_on: "#{Date.current.strftime("%Y-%m")}-01".."#{Date.current.end_of_month}").order(change_kintai_req_on: :asc)
  end
  
  def kintai_part_log #←いらいないかも(Viewがあるから必要かも？)？
    #logger.debug "ここを通ったよ(028)"
  end

  def kintai_part_class
    #logger.debug "ここを通ったよ(029)"
    @year_value = params[:year_value]
    @month_value = params[:month_value]
    
    @year = 2017 + @year_value.to_i
    @log_data = Editaprvl.where(user_id: params[:id]).where(change_kintai_req_on: \
                  "#{Date.strptime("#{@year}-#{@month_value}-01").beginning_of_month}".."#{Date.strptime("#{@year}-#{@month_value}-01").end_of_month}")\
                  .where(change_aprvl_status: "承認").order(change_kintai_req_on: :asc)
  end

private
  def editaprvls_params
    params.permit(editaprvls: [:change_kintai_req_on, :change_started_at, :change_finished_at, :note, :user_id])[:editaprvls]
  end
  
  # beforeアクション
    # ログイン済みユーザーか確認
    def logged_in_user
      unless logged_in?
        store_location
        flash[:danger] = "ログインしてください。"
        redirect_to login_url
      end
    end

    # 正しいユーザーかどうか確認
    def correct_user
      @user = User.find(params[:id])
      redirect_to(root_url) unless current_user?(@user)
    end
    
    def not_admin_user
      redirect_to(root_url) if current_user.admin?
    end

end