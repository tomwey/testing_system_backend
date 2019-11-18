module API
  module V1
    class FollowsAPI < Grape::API
      
      helpers API::SharedParams
      resource :follows, desc: '关注商家接口' do
        desc "我的关注"
        params do
          requires :token, type: String, desc: '用户TOKEN'
        end
        get do
          user = authenticate!
          @merchants = user.followed_merchants.where(verified: true).order('follows.id desc')
          render_json(@merchants, API::V1::Entities::Merchant)
        end # end get
        
        desc "关注商家"
        params do
          requires :token,    type: String, desc: '用户TOKEN'
          requires :merch_id, type: Integer, desc: '商家ID'
        end
        post do
          user = authenticate!
          
          @merchant = Merchant.find_by(merch_id: params[:merch_id])
          if @merchant.blank?
            return render_error(4004, '商家不存在')
          end
          
          if user.followed?(@merchant)
            return render_error(3001, '您已经关注过该商家，不能重复关注')
          end
          
          user.follow!(@merchant)
          
          render_json_no_data
          
        end # end post
        
        desc "取消关注商家"
        params do
          requires :token,    type: String, desc: '用户TOKEN'
          # requires :merch_id, type: Integer, desc: '商家ID'
        end
        post '/:merch_id/cancel' do
          user = authenticate!
          
          @merchant = Merchant.find_by(merch_id: params[:merch_id])
          if @merchant.blank?
            return render_error(4004, '商家不存在')
          end
          
          unless user.followed?(@merchant)
            return render_error(3001, '您还未关注该商家，不能取消关注')
          end
          
          user.unfollow!(@merchant)
          
          render_json_no_data
          
        end # end post
        
      end # end resource
      
    end
  end
end