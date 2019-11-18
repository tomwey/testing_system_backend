class SysFunc < ActiveRecord::Base
  validates :name, :func_name, :code, presence: true
  validates_uniqueness_of :code
  
  has_many :func_actions, dependent: :destroy
  has_many :sys_actions, through: :func_actions
  # has_and_belongs_to_many :sys_actions, join_table: :funcs_actions
  # accepts_nested_attributes_for :func_actions, allow_destroy: true
  
  def sys_action_ids=(ids)
    ids = ids.reject(&:empty?)
    # puts ids
    self.sys_actions = SysAction.where(opened: true, id: ids).order('sort asc')
  end
  def sys_action_ids
    self.sys_actions.pluck(:id)
  end
  
  def selected_actions_for(opts)
    return [] if opts.blank? or opts[:opts].blank? or opts[:opts][:role].blank?
    
    role = opts[:opts][:role]
    
    codes = role.permissions.joins(:sys_action).where(sys_func_id: self.id).pluck('sys_actions.code')
    codes
    
  end
end
