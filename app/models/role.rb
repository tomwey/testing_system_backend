class Role < ActiveRecord::Base
  validates :name, :company_id, presence: true
  validates_uniqueness_of :name, scope: [:company_id, :deleted_at]
  belongs_to :company
  has_and_belongs_to_many :permissions, class_name: 'FuncAction', join_table: :roles_permissions
  has_and_belongs_to_many :accounts
  
  def _permissions=(val)
    return if val.blank?
    
    unless val.is_a? Array
      errors.add(:base, '不正确的权限参数')
      return false
    end
    
    # [{ '100': ['123','456', '789'] }, ]
    temp = []
    val.each do |item|
      item.each do |k,v|
        v.each do |code|
          fa = FuncAction.where(sys_func_id: SysFunc.find_by(code: k).try(:id), sys_action_id: SysAction.find_by(code: code).try(:id)).first
          temp << fa if fa
        end
      end
    end
    
    self.permissions = temp
  end
  
  def sys_funcs
    ids = permissions.pluck(:sys_func_id).uniq
    # a_ids = permissions.pluck(:sys_action_id).uniq
    funcs = SysFunc.where(opened: true, deleted_at: nil).where(id: ids)
    temp = []
    funcs.each do |f|
      hash = {}
      hash[:name] = f.name
      hash[:code] = f.code
      a_ids = permissions.where(sys_func_id: f.id).pluck(:sys_action_id).uniq
      hash[:actions] = API::V1::Entities::SysAction.represent(f.sys_actions.where(id: a_ids, opened: true, deleted_at: nil))
      temp << hash
    end
    temp
  end
  
  def permit_params
    ['name', 'memo', '_permissions']
  end
end
