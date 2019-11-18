class CreateFuncActions < ActiveRecord::Migration
  def change
    create_table :func_actions do |t|
      t.integer :sys_func_id, index: true
      t.integer :sys_action_id, index: true
      t.boolean :opened, default: true

      t.timestamps null: false
    end
  end
end
