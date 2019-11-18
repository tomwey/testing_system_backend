class SysPriceVersion < ActiveRecord::Base
  validates :name, :func_desc, presence: true
  
  has_and_belongs_to_many :func_actions, join_table: :sys_version_func_actions
  accepts_nested_attributes_for :func_actions
end
