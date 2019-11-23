class AttendancesController < ApplicationController
  before_action :correct_or_admin_user,   only: [:zangyo_shinsei]
  before_action :admin_user,     only: [:shukkin_list]

  def create
    @user = User.find(params[:user_id])
    @attendance = @user.attendances.find_by(worked_on: Date.current)
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

  # ### 2．残業申請(申請者側)関係 ######
  # 2-1．モーダル表示（残業申請モーダル画面）
  def zangyo_shinsei
    #logger.debug "ここを通ったよ(010)"
    @user = User.find(params[:id])
    @slct_day = Date.strptime(params[:date]) #.to_s(:date)
    
    #更新データの取得(モーダル画面とDBのリンク付け)
    @zangyoaprvl = Zangyoaprvl.find_by(zangyo_aprvl_req_on: params[:date], zangyo_target_person_id: params[:id])
    unless @zangyoaprvl.present? 
      #更新データがない場合、一旦、承認者を自分のIDでデータ作成(モーダル画面表示するため)
      @zangyoaprvl = Zangyoaprvl.new(user_id: params[:id], zangyo_aprvl_req_on: params[:date], zangyo_target_person_id: params[:id], yuko_flag: 0)
      @zangyoaprvl.save
    end
    
    @shonin_id_show = 0
    if @zangyoaprvl.present? && @zangyoaprvl.yuko_flag == 1
      @shonin_id_show = @zangyoaprvl.user_id
    end
  end
  
  # 2-2．変更送信（残業申請モーダル画面）
  def zangyo_update
    #logger.debug "ここを通ったよ(011)"
    
    #各種値を取得
    @user = User.find(params[:id])                                      #残業申請者ID
    @slct_date = params[:date]                                          #残業申請日
    @yokujitsu_kakunin_check = params[:"yokujitsu_kakunin"]             #翌日(チェック)
    @shonin_id = params[:user][:name]                                   #残業承認者ID

    #残業申請日の申請済みデータの取得(有無チェック用)
    @zangyo_apr_count = Zangyoaprvl.where(zangyo_aprvl_req_on: @slct_date).where(zangyo_target_person_id: @user.id).where(zangyo_aprvl_status: "申請中").where(yuko_flag: 1).count
    
    #残業申請データの登録
    if @zangyo_apr_count > 0
      flash[:danger] = "既に申請済みです。"
    else
      zangyoaprvl_params.each do |id, item|
        @gyomu_memo_tmp = params[:zangyoaprvls][id][:zangyo_note]                 #業務処理内容
        @finished_plan_time_tmp = params[:zangyoaprvls][id][:zangyo_finished_at]  #終了予定時間
        #入力チェック
        if @finished_plan_time_tmp == ""
          flash[:danger] = "「終了予定時間」を入力してください。"
        elsif @gyomu_memo_tmp == "" 
          flash[:danger] = "「業務処理内容」を入力してください。"
        elsif @shonin_id == ""
          flash[:danger] = "「指示者確認㊞」を選択してください。"
        else
          #対象データの取得と更新
          zangyoaprvl = Zangyoaprvl.find(id)
          zangyoaprvl.update_attributes(item)
          @gyomu_memo = zangyoaprvl.zangyo_note                                   #業務処理内容
          @finished_plan_time = zangyoaprvl.zangyo_finished_at                    #終了予定時間

          @finished_plan_at = Time.parse(@slct_date + " " + @finished_plan_time.strftime("%H:%M") + " +0900")
          #残業時間申請日時の翌日設定
          if @yokujitsu_kakunin_check == "1" then
            @finished_plan_at = @finished_plan_at.tomorrow
          end
          zangyoaprvl.user_id = @shonin_id
          zangyoaprvl.zangyo_aprvl_req_on = @slct_date
          zangyoaprvl.zangyo_aprvl_status = "申請中"
          zangyoaprvl.zangyo_finished_at = @finished_plan_at.to_s
          zangyoaprvl.zangyo_note = @gyomu_memo.to_s
          zangyoaprvl.zangyo_target_person_id = @user.id
          zangyoaprvl.yuko_flag = 1
          zangyoaprvl.save
          flash[:success] = "残業申請を送信しました。"
        end
      end
    end
    ############################################

    # 勤怠画面(トップ画面)を再表示
    @first_day_l = Date.strptime(params[:date]).beginning_of_month
    redirect_to user_path(@user, params:{first_day: @first_day_l})
  end

  # ### 3．出勤中社員一覧関係 ######
  def shukkin_list
    @users = User.all
    @shukkin_users = []

    @users.each do |user| 
      if @attendances = user.attendances.find_by(worked_on: Date.current, finished_at: nil)
        @shukkin_users.push(user) if @attendances.started_at.present?
        #debugger
      end
    end
  end

  # ### CSV出力ボタン押下時 #####
  def export
    logger.debug "ここを通ったよ(015)"
    @user = User.find(params[:id])
    @first_day = first_day(params[:date])
    @last_day = @first_day.end_of_month
    @attendances = @user.attendances.where("worked_on >= ?", @first_day).where("worked_on <= ?", @last_day)

    respond_to do |format|
      format.csv do
        send_data render_to_string, filename: "export.csv", type: :csv
      end
    end
  end

  private
    def attendances_params
      params.permit(attendances: [:started_at, :finished_at, :note])[:attendances]
    end
    
    def attendances_zangyo_params
      params.permit(attendances: [:finished_at])[:attendances]
    end
    
    def zangyoaprvl_params
      params.permit(zangyoaprvls: [:zangyo_finished_at, :zangyo_note])[:zangyoaprvls]
    end
    
    # 正しいユーザー、または、管理者ユーザーかどうか確認
    def correct_or_admin_user
      @user = User.find(params[:id])
      redirect_to(root_url) unless current_user?(@user) or current_user.admin?
    end
    
    def admin_user
      redirect_to(root_url) unless current_user.admin?
    end
end
