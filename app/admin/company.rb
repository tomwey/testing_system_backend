ActiveAdmin.register Company do
# See permitted parameters documentation:
# https://github.com/activeadmin/activeadmin/blob/master/docs/2-resource-customization.md#setting-up-strong-parameters
#
permit_params :name, :brand, :logo, :mobile, :license_no, :license_image, :address, :memo, :opened, :vip_expired_at, :_balance, :pid, :sys_ver_id, accounts_attributes: [:id, :name, :avatar, :mobile, :password, :is_admin, :opened, :_destroy]
#
# or
#
# permit_params do
#   permitted = [:permitted, :attributes]
#   permitted << :other if params[:action] == 'create' && current_user.admin?
#   permitted
# end

index do
  selectable_column
  column 'ID', :id
  column :brand
  column :logo do |o|
    image_tag o.logo.url(:large)
  end
  column :name
  column :mobile
  column :license_no
  column :license_image do |o|
    image_tag o.license_image.url
  end
  column :address
  column :opened
  column :vip_expired_at
  column 'at', :created_at
  actions
end

form do |f|
  f.semantic_errors
  f.inputs '基本信息' do
    f.input :name
    f.input :brand
    f.input :logo
    f.input :license_no
    f.input :license_image
    f.input :mobile
    f.input :address
    f.input :vip_expired_at, as: :string
    f.input :_balance, as: :number, label: '余额(元)'
    f.input :pid, as: :select, label: '所属父机构', collection: Company.where(opened: true).map { |c| [c.brand, c.id] }
    f.input :opened
    f.input :sys_ver_id, as: :select, label: '系统套餐', collection: SysPriceVersion.order('sort asc').map { |v| [v.name, v.id] }
    f.input :memo
  end
  f.inputs '超级管理员账号' do
    f.has_many :accounts, allow_destroy: true, heading: '' do |item_form|
      item_form.input :name, as: :string, placeholder: "例如：2018-10-10"
      item_form.input :avatar
      item_form.input :mobile
      item_form.input :password, placeholder: '至少6位'
      item_form.input :opened
      item_form.input :is_admin
    end
  end
  actions
end

end
