class AddWorkEndTimeToUser < ActiveRecord::Migration[5.1]
  def change
    add_column :users, :work_end_time, :datetime, default: Time.zone.parse("2019/02/20 08:00")
  end
end
