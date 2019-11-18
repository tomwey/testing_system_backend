class CreateAuthCodes < ActiveRecord::Migration
  def change
    unless ActiveRecord::Base.connection.table_exists? 'auth_codes'
      create_table :auth_codes do |t|
        t.string :code, limit: 6, null: false
        t.string :mobile, null: false
        t.datetime :activated_at

        t.timestamps null: false
      end
      add_index :auth_codes, :code
      add_index :auth_codes, :mobile
    end
  end
end
