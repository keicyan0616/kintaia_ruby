class CreateEditaprvls < ActiveRecord::Migration[5.1]
  def change
    create_table :editaprvls do |t|
      t.references :user, foreign_key: true
      t.date :change_kintai_req_on
      t.datetime :change_started_at
      t.datetime :change_finished_at
      t.string :note
      t.string :change_aprvl_status
      t.integer :change_target_person_id
      t.datetime :approval_at

      t.timestamps
    end
  end
end
