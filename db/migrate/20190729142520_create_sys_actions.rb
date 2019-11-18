class CreateSysActions < ActiveRecord::Migration
  def change
    create_table :sys_actions do |t|
      t.integer :code
      t.string :name, null: false
      t.string :action_name, null: false
      t.boolean :opened, default: true
      t.integer :sort, default: 0
      t.string :memo

      t.timestamps null: false
    end
    add_index :sys_actions, :code, unique: true
  end
end
