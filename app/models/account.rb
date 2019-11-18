class Account < ActiveRecord::Base
  has_secure_password
  validates :mobile, presence: true, format: { with: /\A1[3|4|5|6|8|7|9][0-9]\d{4,8}\z/ }
  validates :name, presence: true
  validates_uniqueness_of :mobile, scope: [:company_id, :deleted_at]
  validates :password, length: { minimum: 6 }, allow_nil: true
  
  belongs_to :company
  has_and_belongs_to_many :roles
  has_many :permissions, class_name: 'FuncAction', through: :roles
  
  mount_uploader :avatar, AvatarUploader
  
  before_create :generate_id_and_private_token
  def generate_id_and_private_token
    begin
      self.id = SecureRandom.random_number(100000..1000000)
    end while self.class.exists?(:id => id)
    self.private_token = SecureRandom.uuid.gsub('-', '')
  end
  
  def can?(resource_class, actions) 
    if self.is_admin
      return true
    end
    
    func_ids = SysFunc.where(func_name: resource_class.to_s, deleted_at: nil, opened: true).pluck(:id)
    action_ids = SysAction.where(action_name: actions, deleted_at: nil, opened: true).pluck(:id)
    permissions.where(sys_func_id: func_ids, sys_action_id: action_ids, opened: true).count > 0
  end
  
  def func_actions
    func_ids = permissions.where(opened: true).pluck(:sys_func_id).uniq
    temp = []
    func_ids.each do |fid|
      action_ids = permissions.where(opened: true, sys_func_id: fid).pluck(:sys_action_id).uniq
      temp << { resource_code: SysFunc.find_by(id: fid).try(:code), action_codes: SysAction.where(opened: true, deleted_at: nil, id: action_ids).pluck(:code) }
    end
    temp
  end
  
  def role_ids=(val)
    return if val.blank?
    unless val.is_a? Array
      return
    end
    self.roles = Role.where(opened: true, deleted_at: nil, id: val)
  end
  
  def role_ids
    self.roles.where(opened: true, deleted_at: nil).pluck(:id)
  end
  
  def password2=(val)
    self.password_confirmation = val
  end
  
  def permit_params
    ['name', 'mobile', 'password', 'password2', 'role_ids']
  end
  
end
