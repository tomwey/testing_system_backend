class Attachment < ActiveRecord::Base
  validates_presence_of :data
  mount_uploader :data, AttachmentUploader, mount_on: :data_file_name
  
  belongs_to :owner, polymorphic: true
  
  before_create :gen_random_id
  def gen_random_id
    begin
      self.id = SecureRandom.random_number(10000000..100000000)
    end while self.class.exists?(:id => id)
  end
  
end
