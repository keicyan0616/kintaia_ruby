class AddGyomuMemoToAttendance < ActiveRecord::Migration[5.1]
  def change
    add_column :attendances, :gyomu_memo, :string
  end
end
