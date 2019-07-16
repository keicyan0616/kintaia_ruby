class AddEmployerNumberToUsers < ActiveRecord::Migration[5.1]
  def change
    add_column :users, :employer_number, :integer
  end
end
