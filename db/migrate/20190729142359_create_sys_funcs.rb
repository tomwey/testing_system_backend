class CreateSysFuncs < ActiveRecord::Migration
  def change
    create_table :sys_funcs do |t|
      t.integer :code
      t.string :name,       null: false
      t.string :func_name, null: false
      t.boolean :opened, default: true
      t.integer :sort, default: 0
      t.string :memo

      t.timestamps null: false
    end
    add_index :sys_funcs, :code, unique: true
  end
end
