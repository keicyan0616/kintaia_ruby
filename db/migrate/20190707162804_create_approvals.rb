class CreateApprovals < ActiveRecord::Migration[5.1]
  def change
    create_table :approvals do |t|
      t.references :user, foreign_key: true
      t.date :kintai_req_on
      t.string :approval_status
      t.integer :app_target_person_id
      t.datetime :approval_at

      t.timestamps
    end
  end
end
