class AddChangeFirstStartedAtToEditaprvl < ActiveRecord::Migration[5.1]
  def change
    add_column :editaprvls, :change_first_started_at, :datetime
  end
end
