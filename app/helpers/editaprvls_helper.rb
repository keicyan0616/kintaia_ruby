module EditaprvlsHelper

  def user_editaprvls_month_date
    @user.editaprvls.where('change_kintai_req_on >= ? and change_kintai_req_on <= ?', @first_day, @last_day).order('change_kintai_req_on')
  end
  
  def editaprvls_month_date
    Editaprvl.where('change_target_person_id = ? and change_kintai_req_on >= ? and change_kintai_req_on <= ?', @user.id, @first_day, @last_day).order('change_kintai_req_on')
  end

end