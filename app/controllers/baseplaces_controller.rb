class BaseplacesController < ApplicationController
  before_action :admin_user, only: [:kyoten_list, :kyoten_edit, :destroy, :update, :touroku]

  def kyoten_list
    @kyoten = Baseplace.all
    @kyoten_new = Baseplace.new
  end
  
  def kyoten_edit
    #logger.debug "ここを通ったよ(023)"
  end
  
  def destroy
    #logger.debug "ここを通ったよ(021)"
    Baseplace.find_by(id: params[:id]).destroy
    flash[:success] = "拠点情報を削除しました。"
    redirect_to kyoten_list_path
  end

  def update
    #logger.debug "ここを通ったよ(020)"
    @kyoten1 = Baseplace.find_by(kyoten_id: params[:id])
    if @kyoten1.update_attributes(baseplace_params)
      flash[:success] = "拠点情報を更新しました。"
      redirect_to kyoten_list_path
    else
      flash[:danger] = "拠点情報の更新が出来ませんでした。"
      redirect_to kyoten_list_path
    end
  end
  
  def touroku
    @kyoten_id = params[:baseplace][:kyoten_id]
    @kyoten_name = params[:baseplace][:kyoten_name] 
    @kyoten_shurui = params[:baseplace][:kyoten_shurui] 
    kyoten_data = Baseplace.new(kyoten_id: @kyoten_id, kyoten_name: @kyoten_name, kyoten_shurui: @kyoten_shurui)
    if kyoten_data.save
      flash[:success] = "拠点情報を登録しました。"
    else
      flash[:danger] = "拠点情報を登録できませんでした。"
    end
    redirect_to kyoten_list_path
  end
private

  def baseplace_params
    params.require(:baseplace).permit(:kyoten_id, :kyoten_name, :kyoten_shurui)
  end
  
  def admin_user
    redirect_to(root_url) unless current_user.admin?
  end
end