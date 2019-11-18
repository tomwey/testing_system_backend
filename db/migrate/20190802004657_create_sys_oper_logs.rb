class CreateSysOperLogs < ActiveRecord::Migration
  def change
    create_table :sys_oper_logs do |t|
      t.references :owner, polymorphic: true, index: true, null: false # 操作者
      t.string :title, null: false # 操作描述
      t.string :resource_name # 操作的资源
      t.string :action        # 具体某个操作
      t.text :resource_ids    # 保存被操作过的具体资源ID，多个资源用英文逗号分隔
      t.string :ip

      t.timestamps null: false
    end
  end
end
