class CreateRoles < ActiveRecord::Migration
  def change
    create_table :roles do |t|
      t.string :name, null: false
      t.boolean :opened, default: true
      t.string :memo
      t.integer :company_id

      t.timestamps null: false
    end
    add_index :roles, :company_id
  end
end
