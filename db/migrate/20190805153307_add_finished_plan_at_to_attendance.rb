class AddFinishedPlanAtToAttendance < ActiveRecord::Migration[5.1]
  def change
    add_column :attendances, :finished_plan_at, :datetime
  end
end
