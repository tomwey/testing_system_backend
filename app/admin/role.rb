ActiveAdmin.register Role do
# See permitted parameters documentation:
# https://github.com/activeadmin/activeadmin/blob/master/docs/2-resource-customization.md#setting-up-strong-parameters
#
permit_params :name, :opened, :memo, :company_id
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
    f.input :company_id, as: :select, collection: Company.where(opened: true).map { |c| [c.brand, c.id] }
    f.input :name
    f.input :opened
    f.input :memo
  end
  actions
end

end
