class AddKyotenIdToBaseplace < ActiveRecord::Migration[5.1]
  def change
    add_column :baseplaces, :kyoten_id, :integer
  end
end
