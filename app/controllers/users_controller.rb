class UsersController < ApplicationController
  before_action :logged_in_user, only: [:edit, :show, :kintai_kakunin, :index, :update, :destroy, :edit_basic_info, :update_basic_info]
  before_action :correct_user,   only: [:edit, :show]
  before_action :admin_user,     only: [:index, :update, :destroy, :edit_basic_info, :update_basic_info]
  before_action :superior_user,  only: [:kintai_kakunin]
  before_action :not_admin_user, only: [:edit, :show]
  #before_action :correct_or_admin_user, only: [:show, :update]
  #before_action :correct_or_superior_user, only: [:update]
  protect_from_forgery except: :soushin_kintai # soushin_kintaiアクションを除外
  
  # ### ユーザー一覧表示 #####
  def index
      #logger.debug "ここを通ったよ(001)"
      @users = User.paginate(page: params[:page]).search(params[:search])
  end

  # ### 勤怠表示 #####
  def show
    #logger.debug "ここを通ったよ(002)"
    @user = User.find(params[:id])
    @first_day = first_day(params[:first_day])
    @last_day = @first_day.end_of_month
    (@first_day..@last_day).each do |day|
      unless @user.attendances.any? {|attendance| attendance.worked_on == day}
        record = @user.attendances.build(worked_on: day)
        record.save
      end
    end
    @dates = user_attendances_month_date
    @worked_sum = @dates.where.not(started_at: nil).count

    # 勤怠申請通知件数のカウント
    @apr_cnt = Approval.where('user_id = ?', params[:id]).where(approval_status: '申請中').count
    
    # 勤怠申請データの取得(原則1件のみのためfind_byを使用)
    @apr_shinsei_data = Approval.find_by(target_person_id: params[:id], kintai_req_on: @first_day)
    #申請状態のメッセージ作成
    @apr_status_msg = "未"
    @apr_user_name = ""
    if @apr_shinsei_data
      @apr_user_name = User.find(@apr_shinsei_data.user_id).name
      if @apr_shinsei_data.approval_status == "申請中"
        @apr_status_msg = "#{@apr_user_name}" + "に申請中"
      elsif @apr_shinsei_data.approval_status == "承認"
        @apr_status_msg = "#{@apr_user_name}" + "から承認済み"
      elsif @apr_shinsei_data.approval_status == "否認"
        @apr_status_msg = "#{@apr_user_name}" + "から否認"
      end
    end
    #logger.debug "ここを通ったよ(002-3)"
    
    # 勤怠変更知件数のカウント
    @edit_aprvl_cnt = Editaprvl.where('change_target_person_id = ?', params[:id]).where(change_aprvl_status: '申請中').count
    
    # 残業申請通知件数のカウント
    @zangyo_aprvl_cnt = Zangyoaprvl.where('user_id = ?', params[:id]).where(zangyo_aprvl_status: '申請中').where.not(zangyo_finished_at: nil).count
  end

  def new
    @user = User.new
  end

  def create
    @user = User.new(user_params)
    if @user.save
      log_in @user
      flash[:success] = "ユーザーの新規作成に成功しました。"
      redirect_to @user
    else
      render 'new'
    end
  end
  
  def edit
  end

  def update
    #logger.debug "ここを通ったよ(007)"
    @user = User.find(params[:id])
    if @user.update_attributes(user_params)
      flash[:success] = "ユーザー情報を更新しました。"
      redirect_to users_url
    else
      flash[:danger] = "ユーザー情報を更新できませんでした。"
      redirect_to users_url
    end
  end
  
  def destroy
    #logger.debug "ここを通ったよ(022)"
    @user = User.find(params[:id])
    if !current_user?(@user)
      User.find(params[:id]).destroy
      flash[:success] = "ユーザー情報を削除しました。"
      redirect_to users_url
    else
      flash[:danger] = "自分自身のユーザー情報は削除できません。"
      redirect_to users_url
    end
  end

  def edit_basic_info
    @user = User.find(params[:id])
  end

  def update_basic_info
     @user = User.find(params[:id])
     flash[:success] = "何も更新されません。ページがあるだけです。"
     redirect_to @user   
  end
  
  # ### 1．勤怠申請関係 #####---------------------------------------------------------------------------------
  def kintai_shinsei
    #logger.debug "ここを通ったよ(003)"
    @user = User.find(params[:id])
    @apr = Approval.where('user_id = ?', params[:id]).where.not(approval_status: "承認").where.not(approval_status: "否認").order(target_person_id: :asc).order(kintai_req_on: :asc)
  end

  def soushin_kintai
    #logger.debug "ここを通ったよ(005)"
    @user = User.find(params[:id])
    @apr = Approval.where('user_id = ?', params[:id]).where.not(approval_status: "承認").where.not(approval_status: "否認").order(target_person_id: :asc).order(kintai_req_on: :asc)
    
    @apr.each do |app_data|
      @app_tmp = app_data.id
      @shiji_kakunin_id = params[:"shiji_kakunin#{@app_tmp.to_s}"]
      if @shiji_kakunin_id == "1"
        if params[:"note#{@app_tmp.to_s}"] == ""
          app_data.delete
        else
          app_data.approval_status = params[:"note#{@app_tmp.to_s}"]
          app_data.save
        end
      end
    end
    flash[:success] = "変更を送信しました。"
    redirect_to @user 
  end
  
  def kintai_kakunin
    #logger.debug "ここを通ったよ(006)"
    @user = User.find(params[:id])
    
    if @user.admin
      redirect_to(root_url)
    else
      @first_day = first_day(params[:date])
      @last_day = @first_day.end_of_month
      (@first_day..@last_day).each do |day|
        unless @user.attendances.any? {|attendance| attendance.worked_on == day}
          record = @user.attendances.build(worked_on: day)
          record.save
        end
      end
      @dates = user_attendances_month_date
      @worked_sum = @dates.where.not(started_at: nil).count
      
      # 勤怠申請データの取得(原則1件のみのためfind_byを使用)
      @apr_shinsei_data = Approval.find_by(target_person_id: params[:id], kintai_req_on: @first_day)
      #申請状態のメッセージ作成
      @apr_status_msg = "未"
      @apr_user_name = ""
      if @apr_shinsei_data
        @apr_user_name = User.find(@apr_shinsei_data.user_id).name
        if @apr_shinsei_data.approval_status == "申請中"
          @apr_status_msg = "#{@apr_user_name}" + "に申請中"
        elsif @apr_shinsei_data.approval_status == "承認"
          @apr_status_msg = "#{@apr_user_name}" + "から承認済み"
        elsif @apr_shinsei_data.approval_status == "否認"
          @apr_status_msg = "#{@apr_user_name}" + "から否認"
        end
      end
    end
  end

  def month_shinsei
    logger.debug "ここを通ったよ(008)"
    @user = User.find(params[:id])
    @shonin_id = params[:user][:name]
    @first_day = first_day(params[:first_day])
    
    @apr_check_exist = Approval.where(kintai_req_on: @first_day).where(target_person_id: @user.id).where.not(approval_status: "否認").count
    if @apr_check_exist > 0
      flash[:danger] = "既に申請済みです。"
    elsif @shonin_id == ""
      flash[:info] = "申請者を選択してください。"
    else
      @apr = Approval.find_by(kintai_req_on: @first_day, target_person_id: @user.id)
      if @apr.present?
        @apr.user_id = @shonin_id
        @apr.kintai_req_on = @first_day
        @apr.approval_status = "申請中"
        @apr.target_person_id = @user.id
      else
        @apr = Approval.new(user_id: @shonin_id, kintai_req_on: @first_day, approval_status: "申請中", target_person_id: @user.id)
      end
      @apr.save
      flash[:success] = "申請を送信しました。"
    end
    redirect_to user_path(params: {id: @user.id, first_day: @first_day})
  end
  
  # ### 2．残業申請(承認者側)関係 #####-------------------------------------------------------------------------
  # 2-1.画面表示(残業申請承認モーダル画面)
  def zangyo_shinsei_approval
    #logger.debug "ここを通ったよ(012)"
    @user = User.find(params[:id])
    @zangyo_apr = Zangyoaprvl.where('user_id = ?', params[:id]).where.not(zangyo_aprvl_status: "承認").where.not(zangyo_aprvl_status: "否認").where(yuko_flag: 1)\
                  .order(zangyo_target_person_id: :asc).order(zangyo_aprvl_req_on: :asc)
  end
  
  # 2-2.残業申請承認(残業申請承認モーダル画面)
  def soushin_zangyo_shinsei
    #logger.debug "ここを通ったよ(013)"
    @user = User.find(params[:id])
    @zangyo_apr = Zangyoaprvl.where('user_id = ?', params[:id]).where.not(zangyo_aprvl_status: "承認").where.not(zangyo_aprvl_status: "否認").where(yuko_flag: 1)\
                  .order(zangyo_target_person_id: :asc).order(zangyo_aprvl_req_on: :asc)
    
    @zangyo_apr.each do |zangyo_app_data|
      @app_tmp = zangyo_app_data.id
      @shiji_kakunin_id = params[:"zangyo_shiji_kakunin#{@app_tmp.to_s}"]
      if @shiji_kakunin_id == "1"
        if params[:"note#{@app_tmp.to_s}"] == ""
          zangyo_app_data.delete
        else
          zangyo_app_data.zangyo_aprvl_status = params[:"note#{@app_tmp.to_s}"]
          zangyo_app_data.save
        end
      end
    end
    flash[:success] = "変更を送信しました。"
    redirect_to @user 
  end

  def import
    if params[:file].blank?
      flash[:danger] = "CSVファイルを選択してください。"
    else
      # fileはtmpに自動で一時保存される
      current_user_count = ::User.count
      User.import(params[:file])
      registered_count = User.count - current_user_count
      flash[:success] = "ユーザーを#{registered_count}件登録しました。"
    end
    redirect_to users_url
  end

private

  def user_params
    params.require(:user).permit(:name, :email, :affiliation, :employer_number, :uid, :password, :basic_work_time, :designated_work_start_time, :designated_work_end_time )
  end

  def basic_info_params
    params.require(:user).permit(:basic_work_time, :designated_work_start_time)
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
    
    def admin_user
      redirect_to(root_url) unless current_user.admin?
    end
    
    def not_admin_user
      redirect_to(root_url) if current_user.admin?
    end
    
    def superior_user
      redirect_to(root_url) unless current_user.superior?
    end
    
    # 正しいユーザー、または、管理者ユーザーかどうか確認
    def correct_or_admin_user
      @user = User.find(params[:id])
      redirect_to(root_url) unless current_user?(@user) or current_user.admin?
    end
    
    # 正しいユーザー、または、上長ユーザーかどうか確認
    def correct_or_superior_user
      @user = User.find(params[:id])
      redirect_to(root_url) unless current_user?(@user) or current_user.superior?
    end
end