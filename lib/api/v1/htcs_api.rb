# require 'rest-client'
require 'geokit'
module API
  module V1
    class HtcsAPI < Grape::API
      
      helpers API::SharedParams
      
      resource :app, desc: '跟APP全局配置相关的接口' do
        desc "获取配置"
        get :configs do
          { code: 0, message: 'ok', data: {  } }
        end # end configs
        
        desc "获取微信JSSDK配置数据"
        params do
          requires :url, type: String, desc: '需要签名的url'
        end
        get :wx_config do
          url = (params[:url].start_with?('http://') or params[:url].start_with?('https://')) ? params[:url] : SiteConfig.send(params[:url])
          json = Wechat::Sign.sign_package(url)
          { code: 0, message: 'ok', data: json }
        end # end get
        
      end # end resource 
      
      resource :shops, desc: "门店相关接口" do
        desc "获取附近的门店"
        params do
          optional :uid, type: String, desc: '会员ID'
          optional :loc, type: String, desc: '经纬度，例如：lng,lat'
        end
        get :nearby do
          @shops = Shop.where(opened: true).order('sort desc')
          if params[:loc].blank?
            loc = client_loc_from_ip
            if loc
              lng,lat = loc
              origin = [lat, lng]
            else
              origin = nil
            end
          else
            loc = params[:loc].split(',')
            if loc.length > 1
              origin = [loc[1], loc[0]]
            else
              origin = nil
            end
          end
          return render_error(4004, '未获取到位置信息') if origin.blank?
          
          @shops = @shops.by_distance(origin: origin)
          render_json(@shops, API::V1::Entities::Shop)
        end # end get nearby
      end # end resource
      
      resource :vip, desc: "VIP相关接口" do
        desc "VIP绑定"
        params do
          requires :mobile, type: String, desc: '手机号'
          requires :code, type: String, desc: '验证码'
          optional :name, type: String, desc: "名字"
          optional :idcard, type: String, desc: "身份证"
        end
        post :bind do
          mobile = params[:mobile]
          code = params[:code]
          
          return render_error(-1, '手机号不正确') unless check_mobile(mobile)
          
          @code = AuthCode.where(mobile: mobile, code: code, activated_at: nil).first
          if @code.blank?
            return render_error(5005, '验证码不正确或已激活')
          else
            @card = VipCardInfo.where(mobile: mobile).first
            if @card.blank?
              @card = VipCardInfo.new
              @card.mobile = mobile
              @card.vip_name = params[:name]
              @card.idcard = params[:idcard]
              @card.save!
            end
      
            @code.activated_at = Time.zone.now
            @code.save!
            
            # has_bind_profile = @user.profile.present?
            
            return { code: 0, message: 'ok', data: {
              card_id: @card.card_id
            } }
          end
          
        end # end post bind
        
        desc "获取会员卡信息"
        params do
          requires :id, type: String, desc: '会员卡号'
        end
        get '/:id' do
          @card = VipCardInfo.find_by(card_id: params[:id])
          return render_error(4004, '会员卡不存在') if @card.blank?
          render_json(@card, API::V1::Entities::VipCardInfo)
        end # end get
      end # end resource 
      
    end
  end
end