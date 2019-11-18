class CreateCompanies < ActiveRecord::Migration
  def change
    create_table :companies do |t|
      t.string :name, null: false
      t.string :brand, null: false
      t.string :logo
      t.string :mobile, null: false
      t.string :license_no, null: false
      t.string :license_image, null: false
      t.string :address, null: false
      t.datetime :vip_expired_at
      t.integer :balance, default: 0
      t.boolean :opened, default: true
      t.integer :sys_ver_id
      t.integer :pid, index: true
      t.string :memo

      t.timestamps null: false
    end
    add_index :companies, :sys_ver_id
  end
end
