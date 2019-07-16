class UsersController < ApplicationController
  before_action :logged_in_user, only: [:edit, :update]
  before_action :correct_user,   only: [:edit]
  before_action :admin_user,     only: [:index, :destroy, :edit_basic_info, :update_basic_info, :kintai_kakunin]
  before_action :correct_or_admin_user, only: [:show, :update]
  protect_from_forgery except: :soushin_kintai # soushin_kintaiアクションを除外
  
  def index
      #logger.debug "ここを通ったよ(001)"
      @users = User.paginate(page: params[:page]).search(params[:search])
  end

  def show
    logger.debug "ここを通ったよ(002)"
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
    logger.debug "ここを通ったよ(002-1)"
    @apr_cnt = Approval.where('user_id = ?', params[:id]).where(approval_status: '申請中').count
    logger.debug "ここを通ったよ(002-2)"
    @apr_status = Approval.where('user_id = 1').where('target_person_id = ?', params[:id]).where(kintai_req_on: "#{@first_day}").select(:approval_status) #どの承認者に送ったものか(user_id)で絞らないとまだダメかも
    logger.debug "ここを通ったよ(002-3)"
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
    logger.debug "ここを通ったよ(007)"
    if @user.update_attributes(user_params)
      flash[:success] = "ユーザー情報を更新しました。"
      redirect_to @user
    else
      render 'edit'
    end
  end
  
  def destroy
    User.find(params[:id]).destroy
    flash[:success] = "削除しました。"
    redirect_to users_url
  end

  def edit_basic_info
    @user = User.find(params[:id])
  end

  def update_basic_info
    @user = User.find(params[:id])
    @users = User.all
    
    @users.each do |user1|
      if !user1.update_attributes(basic_info_params)
        render 'edit_basic_info'
      end
    end
    flash[:success] = "基本情報を更新しました。"
    redirect_to @user   
  end
  
  ### 勤怠申請関係 ### ----------------------------------------------------------------
  def kintai_shinsei
    logger.debug "ここを通ったよ(003)"
    @user = User.find(params[:id])
    @apr = Approval.where('user_id = ?', params[:id]).order(target_person_id: :asc).order(kintai_req_on: :asc)
  end
  
  #def approval
  #  logger.debug "ここを通ったよ(004)"
  #  @apr = Approval.find(params[:id])
  #end

  def soushin_kintai
    logger.debug "ここを通ったよ(005)"
    @user = User.find(params[:id])
    @apr = Approval.where('user_id = ?', params[:id]).order(target_person_id: :asc).order(kintai_req_on: :asc)
    
    @apr.each do |app_data|
      @app_tmp = app_data.id
      @shiji_kakunin_id = params[:"shiji_kakunin#{@app_tmp.to_s}"]
      if @shiji_kakunin_id == "1"
        app_data.approval_status = params[:"note#{@app_tmp.to_s}"]
        app_data.save
      end
    end
    #@aps = params[:note4]
    #@aps = params[:"note#{@app_tmp.to_s}"]
    #flash[:success] = @shiji_kakunin_id
    flash[:success] = "変更を送信しました。"
    redirect_to @user 
  end
  
  def kintai_kakunin
    logger.debug "ここを通ったよ(006)"
    @user = User.find(params[:id])
    @first_day = first_day(params[:date])
    #redirect_to user_path(params: {id: @user.id, first_day: @first_day, read_only_flag: true})
    #redirect_to user_path(params: {id: @user.id, first_day: "2019-04-01"})
    
    #@user = User.find(params[:id])
    #@first_day = first_day(params[:first_day])
    @last_day = @first_day.end_of_month
    (@first_day..@last_day).each do |day|
      unless @user.attendances.any? {|attendance| attendance.worked_on == day}
        record = @user.attendances.build(worked_on: day)
        record.save
      end
    end
    @dates = user_attendances_month_date
    @worked_sum = @dates.where.not(started_at: nil).count
  end

private

  def user_params
    params.require(:user).permit(:name, :email, :department, :employer_number, :uid, :password, :basic_time, :work_time, :work_end_time )
  end

  def basic_info_params
    params.require(:user).permit(:basic_time, :work_time)
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
    
    # 正しいユーザー、または、管理者ユーザーかどうか確認
    def correct_or_admin_user
      @user = User.find(params[:id])
      redirect_to(root_url) unless current_user?(@user) or current_user.admin?
    end
end