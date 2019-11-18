ActiveAdmin.register SysPriceVersion do
# See permitted parameters documentation:
# https://github.com/activeadmin/activeadmin/blob/master/docs/2-resource-customization.md#setting-up-strong-parameters
#
permit_params :name, :price, :func_desc, :opened, :sort, :limits, func_action_ids: []
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
  column :func_desc, sortable: false do |o|
    raw(o.func_desc)
  end
  column '模块功能', sortable: false do |o|
    raw(o.func_actions.map { |fa| "#{fa.sys_func.try(:name)}#{fa.sys_action.try(:name)}" }.join('<br>'))
  end
  column :price
  column :limits, sortable: false
  column :opened, sortable: false
  column :sort
  column 'at', :created_at
  actions
end

form do |f|
  f.semantic_errors
  f.inputs do
    f.input :name
    
    f.input :func_desc, as: :text, input_html: { class: 'redactor' }, placeholder: '网页内容，支持图文混排', hint: '网页内容，支持图文混排'
    f.input :price
    f.input :func_actions, as: :check_boxes, label: '模块功能', collection: FuncAction.where(opened: true).map { |a| ["#{a.sys_func.try(:name)}#{a.sys_action.try(:name)}", a.id] }
    f.input :limits
    f.input :opened
    f.input :sort
  end
  actions
end

end
