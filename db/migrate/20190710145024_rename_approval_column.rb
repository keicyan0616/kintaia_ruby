class RenameApprovalColumn < ActiveRecord::Migration[5.1]
  def change
    rename_column :approvals, :user_id, :app_user_id
    rename_column :approvals, :app_target_person_id, :target_person_id
  end
end
