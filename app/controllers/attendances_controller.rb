class AttendancesController < ApplicationController
  before_action :correct_or_admin_user,   only: [:edit]

  def create
    @user = User.find(params[:user_id])
    @attendance = @user.attendances.find_by(worked_on: Date.today)
    if @attendance.started_at.nil?
      @attendance.update_attributes(started_at: current_time)
      flash[:info] = 'おはようございます。'
    elsif @attendance.finished_at.nil?
      @attendance.update_attributes(finished_at: current_time)
      flash[:info] = 'おつかれさまでした。'
    else
      flash[:danger] = 'トラブルがあり、登録出来ませんでした。'
    end
    redirect_to @user
  end
  
  # --- 勤怠編集画面 表示 -----
  def edit
    @user = User.find(params[:id])
    @first_day = first_day(params[:date])
    @last_day = @first_day.end_of_month
    @dates = user_attendances_month_date
  end
  
  # 勤怠編集画面 更新送信
  def update
    @user = User.find(params[:id])
    if attendances_invalid?
      attendances_params.each do |id, item|
        attendance = Attendance.find(id)
        attendance.update_attributes(item)
      end
      flash[:success] = '勤怠情報を更新しました。'
      redirect_to user_path(@user, params:{first_day: params[:date]})
    else
      flash[:danger] = "不正な時間入力がありました、再入力してください。"
      redirect_to edit_attendances_path(@user, params[:date])
    end
  end
  
  # --- 残業申請画面 表示 -----
  def zangyo_shinsei
    logger.debug "ここを通ったよ(010)"
    @user = User.find(params[:id])
    @slct_day = Date.strptime(params[:date]) #.to_s(:date)
    @attendance = @user.attendances.find_by(worked_on: params[:date])
    #@first_day = first_day(params[:date])
    #@last_day = @first_day.end_of_month
    #@attend_date = Attendance.find(1)
    #@dates = user_attendances_month_date
  end
  
  # 残業申請画面 更新送信
  def zangyo_update
    logger.debug "ここを通ったよ(011)"
    @user = User.find(params[:id])
    @slct_date = params[:date]
    @shinsei_id = params[:user][:name]
    #@attendance = @user.attendances.find_by(worked_on: params[:date])
    #if attendances_invalid?
    @yokujitsu_kakunin_check = params[:"yokujitsu_kakunin"]
    
    #@zangyo_apr_check_exist = ZangyoAprvl.find_by(user_id: @shinsei_id, zangyo_aprvl_req_on: @slct_date, zangyo_target_person_id: @user.id)
    #if @zangyo_apr_check_exist
    #  flash[:danger] = "既に申請済みです。"
    #else
      @zangyo_apr_exist = Zangyoaprvl.find_by(user_id: @shinsei_id, zangyo_aprvl_req_on: @slct_date, zangyo_target_person_id: @user.id)
      
      if @zangyo_apr_exist
        flash[:danger] = "既に申請済みです。"
      #elsif @shinsei_id == ""
      #  flash[:info] = "申請者を選択してください。"
      else
        attendances_zangyo_params.each do |id, item|
          attendance = Attendance.find(id)
          attendance.update_attributes(item)
          @gyomu_memo = attendance.gyomu_memo
          
          if @yokujitsu_kakunin_check == "1" then
            @finished_plan_at = Time.parse(attendance.worked_on.tomorrow.strftime("%Y-%m-%d") + " " + attendance.finished_plan_at.strftime("%H:%M") + " +0900")
          else  
            @finished_plan_at = Time.parse(attendance.worked_on.strftime("%Y-%m-%d") + " " + attendance.finished_plan_at.strftime("%H:%M") + " +0900")
          end
          #@calc_work_datetime = Time.parse(zangyo_data.zangyo_aprvl_req_on.strftime("%Y-%m-%d") + " " + @target_user.work_end_time.strftime("%H:%M") + " +0900")
        end
        ##### まだこの辺りを直さないといけない #####
        # updateにしないといけない
        @zangyo_apr = Zangyoaprvl.new(user_id: @shinsei_id, zangyo_aprvl_req_on: @slct_date, zangyo_aprvl_status: "申請中", zangyo_finished_at: @finished_plan_at.to_s, 
                                    zangyo_note: @gyomu_memo.to_s, zangyo_target_person_id: @user.id)
        @zangyo_apr.save 
        flash[:success] = '残業申請を送信しました。'
        #flash[:success] = "申請を送信しました。" # + @num.to_s
      end
      #flash[:success] = "申請を送信しました。" # + @num.to_s      
      #zangyo_app_data.zangyo_aprvl_status = params[:"note#{@app_tmp.to_s}"]
      #zangyo_app_data.save
      ############################################
          
      
      #redirect_to user_path(@user, params:{first_day: params[:date]})
    #else
      #flash[:danger] = "不正な時間入力がありました、再入力してください。"
      #redirect_to edit_attendances_path(@user, params[:date])
    #end
    #end

    @first_day_l = Date.strptime(params[:date]).beginning_of_month
    redirect_to user_path(@user, params:{first_day: @first_day_l})
  end

  private
    def attendances_params
      params.permit(attendances: [:started_at, :finished_at, :note])[:attendances]
    end
    
    def attendances_zangyo_params
      params.permit(attendances: [:finished_plan_at, :gyomu_memo])[:attendances]
      #params.permit(attendances: [:finished_at, :note])[:attendances]
    end
    
    # 正しいユーザー、または、管理者ユーザーかどうか確認
    def correct_or_admin_user
      @user = User.find(params[:id])
      redirect_to(root_url) unless current_user?(@user) or current_user.admin?
    end
end
