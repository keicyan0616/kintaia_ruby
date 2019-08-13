class CreateZangyoaprvls < ActiveRecord::Migration[5.1]
  def change
    create_table :zangyoaprvls do |t|
      t.references :user, foreign_key: true
      t.date :zangyo_aprvl_req_on
      t.datetime :zangyo_finished_at
      t.string :zangyo_note
      t.string :zangyo_aprvl_status
      t.integer :zangyo_target_person_id
      t.datetime :approval_at

      t.timestamps
    end
  end
end
