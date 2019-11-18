class SysAction < ActiveRecord::Base
  validates :name, :action_name, :code, presence: true
  validates_uniqueness_of :code
  # has_and_belongs_to_many :sys_funcs, join_table: :funcs_actions
  has_many :func_actions, dependent: :destroy
  has_many :sys_funcs, through: :func_actions
end
