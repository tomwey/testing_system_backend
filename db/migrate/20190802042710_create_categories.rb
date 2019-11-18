class CreateCategories < ActiveRecord::Migration
  def change
    create_table :categories do |t|
      t.string :name, null: false
      t.integer :company_id
      t.boolean :opened, default: true
      t.string :memo
      t.datetime :deleted_at

      t.timestamps null: false
    end
    add_index :categories, :company_id
  end
end
