class CreateSysVersionFuncActions < ActiveRecord::Migration
  def change
    create_table :sys_version_func_actions, id: false do |t|
      t.belongs_to :sys_price_version
      t.belongs_to :func_action
    end
  end
end
