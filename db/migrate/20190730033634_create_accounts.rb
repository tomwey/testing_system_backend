class CreateAccounts < ActiveRecord::Migration
  def change
    create_table :accounts do |t|
      t.string :name, null: false
      t.string :avatar
      t.string :mobile, null: false
      t.string :password_digest
      t.string :private_token
      t.boolean :opened, default: true
      t.boolean :is_admin, default: false
      t.datetime :last_login_at
      t.string :last_login_ip
      t.integer :company_id, null: false

      t.timestamps null: false
    end
    add_index :accounts, :company_id
    add_index :accounts, :mobile
  end
end
