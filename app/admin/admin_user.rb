ActiveAdmin.register AdminUser do
  menu label: '后台管理员账号', priority: 100
  
  # permit_params :email, :password, :password_confirmation, permission_ids: []
  
  permit_params do
    params = [:email, :password, :password_confirmation]
    params.push permission_ids: [] if current_admin_user.admin? or authorized?(:set_permissions, AdminUser)
    params
  end
  
  config.filters = false
  
  actions :all, except: [:show]
  
  controller do
    def scoped_collection # 过滤站长账号
      current_admin_user.super_admin? ? AdminUser.all : AdminUser.where.not(email: Setting.admin_emails)
    end
    
    # def update_resource(object, attributes)
    #   authorize! :set_permissions, object
    #   super(object, attributes)
    # end
    
  end
  
  index do
    selectable_column
    id_column
    column :email
    column :current_sign_in_at
    column :sign_in_count
    column '拥有权限' do |o|
      if o.super_admin?
        '所有权限'
      else
        raw(o.permissions.all.map { |p| ["#{p.action_name}#{p.func_name}"] }.join('<br>'))
      end
    end
    column :created_at
    actions
  end

  # filter :email
  # filter :current_sign_in_at
  # filter :sign_in_count
  # filter :created_at
  
  member_action :unbind, method: :put do
    resource.unbind!
    redirect_to collection_path, notice: '解绑成功'
  end

  # form do |f|
  #   f.inputs '修改密码' do
  #     # f.input :email
  #     f.input :password
  #     f.input :password_confirmation
  #   end
  #   f.actions
  # end
  
  form do |f|
    f.inputs "管理员信息" do
      if f.object.new_record?
        f.input :email
      end
      f.input :password
      f.input :password_confirmation
      if current_admin_user.admin? or authorized?(:set_permissions, f.object)
        render partial: 'permission_field', locals: { f: f } 
      end
      
      # f.input :role, as: :radio, collection: Admin.roles.map { |role| [I18n.t("common.#{role}"), role] }
    end
    f.actions
  end

end
