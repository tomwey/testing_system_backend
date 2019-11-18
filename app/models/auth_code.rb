class AuthCode < ActiveRecord::Base
  def self.create_code!(mobile, code_length = 4)
    str_length = code_length + 1
    code_str = rand.to_s[2..str_length]
    
    code = AuthCode.create!(code: code_str, mobile: mobile)
    code
  end
  
  def self.check_code_for(mobile, code)
    return nil if mobile.blank? or code.blank?
    where('mobile = ? and code = ? and activated_at is null', mobile, code).first
  end
  
  def active
    self.update_attribute(:activated_at, Time.zone.now)
  end
end
