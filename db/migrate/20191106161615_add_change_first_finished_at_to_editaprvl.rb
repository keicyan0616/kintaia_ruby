class AddChangeFirstFinishedAtToEditaprvl < ActiveRecord::Migration[5.1]
  def change
    add_column :editaprvls, :change_first_finished_at, :datetime
  end
end
