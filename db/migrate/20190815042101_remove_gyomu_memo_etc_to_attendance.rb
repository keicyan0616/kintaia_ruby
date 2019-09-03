class RemoveGyomuMemoEtcToAttendance < ActiveRecord::Migration[5.1]
  def change
    remove_column :attendances, :gyomu_memo, :string
    remove_column :attendances, :finished_plan_at, :datetime
  end
end
