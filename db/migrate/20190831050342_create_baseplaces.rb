class CreateBaseplaces < ActiveRecord::Migration[5.1]
  def change
    create_table :baseplaces do |t|
      t.string :kyoten_name
      t.string :kyoten_shurui

      t.timestamps
    end
  end
end
