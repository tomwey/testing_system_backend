class CreateRolesPermissions < ActiveRecord::Migration
  def change
    create_table :roles_permissions, id: false do |t|
      t.belongs_to :role
      t.belongs_to :func_action
    end
  end
end
