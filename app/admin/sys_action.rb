ActiveAdmin.register SysAction do
# See permitted parameters documentation:
# https://github.com/activeadmin/activeadmin/blob/master/docs/2-resource-customization.md#setting-up-strong-parameters
#
permit_params :code, :name, :action_name, :opened, :sort, :memo
#
# or
#
# permit_params do
#   permitted = [:permitted, :attributes]
#   permitted << :other if params[:action] == 'create' && current_user.admin?
#   permitted
# end

form do |f|
  f.semantic_errors
  f.inputs do
    f.input :name
    f.input :action_name
    f.input :code
    f.input :opened
    f.input :sort
    f.input :memo
  end
  actions
end

end
