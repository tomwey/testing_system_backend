ActiveAdmin.register SysFunc do
# See permitted parameters documentation:
# https://github.com/activeadmin/activeadmin/blob/master/docs/2-resource-customization.md#setting-up-strong-parameters
#
permit_params :code, :name, :func_name, :opened, :sort, :memo, sys_action_ids: []
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
  column '#', :id
  column :name, sortable: false
  column :func_name, sortable: false
  column '功能操作', sortable: false do |o|
    o.sys_actions.map {|a| a.name}.join(',')
  end
  column :code
  column :opened
  column :sort
  column 'at', :created_at
  actions
end

form do |f|
  f.semantic_errors
  f.inputs '基础信息' do
    f.input :name
    f.input :func_name
    f.input :code
    f.input :sys_action_ids, as: :check_boxes, label: '功能操作', collection: SysAction.where(opened: true).order('sort asc').map { |a| [a.name, a.id] }
    f.input :opened
    f.input :sort
    f.input :memo
  end
  # f.inputs '功能操作' do
  #   f.has_many :func_actions, heading: '' do |bf|
  #     bf.input :sys_action_ids, as: :check_boxes, label: '功能操作', collection: SysAction.where(opened: true).order('sort asc').map { |a| [a.name, a.id] }
  #   end
  # end
  actions
end

end
