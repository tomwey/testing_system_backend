require 'rest-client'
module API
  module V1
    class AppAPI < Grape::API
      helpers API::SharedParams
      resource :app, desc: "机构配置相关的接口" do
        desc "获取配置"
        params do
          requires :cid, type: Integer, desc: '机构ID'
        end
        get :configs do
          oid = params[:cid]
          @company = Company.find_by(id: oid)
          if @company.blank? or @company.deleted_at.present?
            return render_error(4004, '机构不存在')
          end
          render_json(@company, API::V1::Entities::SimpleCompany)
        end # end get configs
      end # end resource
    end
  end
end