class FuncAction < ActiveRecord::Base
  # validates :sys_func_id, :sys_action_id, presence: true
  validates_uniqueness_of :sys_action_id, scope: :sys_func_id
  belongs_to :sys_func
  belongs_to :sys_action
  
  has_and_belongs_to_many :roles, class_name: 'Role', join_table: :roles_permissions
  
  def resource_code
    
  end
  
  def action_codes
    
  end
  
end
