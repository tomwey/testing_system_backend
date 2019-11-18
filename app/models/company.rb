class Company < ActiveRecord::Base
  validates :name, :brand, :logo, :mobile, :license_no, :license_image, :address, presence: true
  belongs_to :parent, class_name: 'Company', foreign_key: :pid
  has_many :children, class_name: 'Company', foreign_key: :pid
  
  has_many :accounts, dependent: :destroy
  # has_many :admin_account, class_name: 'Account', dependent: :destroy
  accepts_nested_attributes_for :accounts
  
  mount_uploader :logo, AvatarUploader
  mount_uploader :license_image, PosterUploader
  
  before_create :gen_random_id
  def gen_random_id
    begin
      self.id = SecureRandom.random_number(100000..1000000)
    end while self.class.exists?(:id => id)
  end
  
  def _balance=(val)
    if val.present?
      self.balance = (val.to_f * 100).to_i
    end
  end
  
  def _balance
    '%.2f' % (self.balance / 100.0)
  end
  
  def logo_id=(val)
    asset = Attachment.find_by(id: val)
    if asset
      self.remote_logo_url = asset.data.url
    end
  end
  
  def license_image_id=(val)
    asset = Attachment.find_by(id: val)
    if asset
      self.remote_license_image_url = asset.data.url
    end
  end
  
  def logo_url
    if logo.blank?
      ''
    else
      logo.url(:big)
    end
  end
  
  def license_image_url
    if license_image.blank?
      ''
    else
      license_image.url
    end
  end
  
  # 关联管理员账号
  def admin=(val)
    unless val.is_a? Hash
      return
    end
    
    asset = Attachment.find_by(id: val['avatar'])
    avatar_url = nil
    if asset
      avatar_url = asset.data.url
    end
    if self.new_record?
      self.accounts.build(name: val['name'], remote_avatar_url: avatar_url, mobile: val['mobile'], password: val['password'], is_admin: true)
    else
      account = self.accounts.where(is_admin: true, id: val['id']).first
      account.name = val['name']
      account.remote_avatar_url = avatar_url
      account.save!
    end
  end
  
  def left_days
    if vip_expired_at.blank?
      return "系统还未开通"
    end
    
    if vip_expired_at.end_of_day < Time.zone.now
      return "已过期"
    end
    
    days = (vip_expired_at.to_date - Time.zone.now.to_date).to_i
    if days < 0
      return "已过期"
    end
    
    if days == 0
      return "即将过期"
    end
    
    return "还剩#{days}天"
  end
  
  def permit_params
    ['name', 'brand', 'logo_id', 'license_no', 'license_image_id', 'mobile', 'address', '_balance', 'memo', 'admin']
  end
end
