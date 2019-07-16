class RenameApprovalColumn2 < ActiveRecord::Migration[5.1]
  def change
    rename_column :approvals, :app_user_id, :user_id
  end
end
