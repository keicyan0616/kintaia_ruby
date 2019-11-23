class SessionsController < ApplicationController
  def new
  end

  #def create
  #  user = User.find_by(email: params[:session][:email].downcase)
  #  if user && user.authenticate(params[:session][:password])
  #    log_in user
  #    remember user
  #    redirect_back_or user
  #  else
  #    flash.now[:danger] = 'メールアドレスとパスワードの情報が一致しませんでした。'
  #    render 'new'
  #  end
  #end

  def create
    user = User.find_by(email: params[:session][:email].downcase)
    if user && user.authenticate(params[:session][:password])
      log_in user
      params[:session][:remember_me] == '1' ? remember(user) : forget(user)
      if current_user.admin?
        redirect_back_or users_path
      else
        redirect_back_or user
      end
      #redirect_to user
    else
      flash.now[:danger] = 'メールアドレスとパスワードの情報が一致しませんでした。'
      render :new
    end
  end

  def destroy
    log_out if logged_in?
    flash[:success] = 'ログアウトしました。'
    redirect_to root_url
  end
end