class AddYukoFlagToZangyoaprvl < ActiveRecord::Migration[5.1]
  def change
    add_column :zangyoaprvls, :yuko_flag, :integer
  end
end
