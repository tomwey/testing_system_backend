module API
  module V1
    class UsersAPI < Grape::API
      
      helpers API::SharedParams
      
      # 获取用户账号登录地址
      resource :u, desc: '网页授权登录接口' do
        desc "获取登录地址"
        params do
          optional :url, type: String, desc: '需要授权登录的H5页面地址'
        end
        get :auth do
          
          # redirect_url  = "http://hhd.afterwind.cn/auth/redirect"
          
          ua = request.user_agent
          is_wx_browser = ua.include?('MicroMessenger') || ua.include?('webbrowser')
          
          if is_wx_browser
            # puts '是微信浏览器'
            # url = request.original_url
            
            redirect_url = "#{SiteConfig.wx_auth_redirect_uri}?provider=wechat&from_url=#{params[:url]}"
            # redirect_url  = "#{SiteConfig.auth_redirect_uri}?url=#{url}&provider=wechat"#"#{wechat_auth_redirect_url}?url=#{request.original_url}"

            auth_url = "https://open.weixin.qq.com/connect/oauth2/authorize?appid=#{SiteConfig.wx_app_id}&redirect_uri=#{Rack::Utils.escape(redirect_url)}&response_type=code&scope=snsapi_userinfo&state=redpack#wechat_redirect"
            # redirect_to @wx_auth_url
          else
            
            redirect_url = "http://hhd.afterwind.cn/redirect?provider=qq&from_url=#{params[:url]}"
            
            auth_url = "https://graph.qq.com/oauth2.0/authorize?response_type=code&client_id=#{SiteConfig.qq_app_id}&redirect_uri=#{Rack::Utils.escape(redirect_url)}&scope=get_user_info"
          end
          
          { code: 0, message: 'ok', data: { url: auth_url } }
          
        end # end get auth
        
        desc "绑定三方账号"
        params do
          requires :code, type: String, desc: '三方登录返回的code'
          requires :provider, type: String, desc: '三方平台名称'
          optional :rid, type: String, desc: '红包ID'
        end
        post :auth_bind do
          u = UserAuth.create_user(params[:provider], params[:code], "http://hhd.afterwind.cn/auth/redirect?provider=qq")
          if u.blank?
            return render_error(4003, '认证登录失败')
          end
          
          { code: 0, message: 'ok', data: { token: u.private_token } }
        end # end auth_bind
        
      end # end resource u
      
      # 用户账号管理
      resource :account, desc: "注册登录接口" do
        desc "用户登录"
        params do
          requires :mobile, type: String, desc: '手机号'
          requires :code,   type: String, desc: '验证码'
          optional :chn_id, type: String, desc: '来源渠道'
        end
        post :login do
          mobile = params[:mobile]
          code = params[:code]
          
          @code = AuthCode.where(mobile: mobile, code: code, activated_at: nil).first
          if @code.blank?
            return render_error(5005, '验证码不正确')
          else
            @user = User.where(mobile: mobile).first_or_create!
      
            @code.activated_at = Time.zone.now
            @code.save!
            
            if params[:chn_id].present?
              @chn = Channel.find_by(uniq_id: params[:chn_id])
              if @chn
                @user.from_chn_id = @chn.id
                @user.save!
              end
            end
            
            # has_bind_profile = @user.profile.present?
            
            return { code: 0, message: 'ok', data: {
              token: @user.private_token,
              is_authed: @user.idcard.present?
            } }
          end
          
        end # end post login
        
        desc "APP用户简单注册"
        params do
          requires :uuid,  type: String, desc: '用户设备唯一ID'
          requires :model, type: String, desc: '设备名称'
          requires :os,    type: String, desc: '操作系统'
          requires :osv,   type: String, desc: '系统版本'
          optional :uname, type: String, desc: '设备用户名字'
          optional :screen, type: String, desc: '设备分辨率'
          optional :lang_code, type: String, desc: '国家语言，例如：zh_CN'
        end
        post :create do
          uuid = params[:uuid]          
          device = UserDevice.find_by(uuid: uuid)
          if device.blank?
            device = UserDevice.new(uuid: uuid, 
                                    model: params[:model], 
                                    os: params[:os], 
                                    os_version: params[:osv],
                                    uname: params[:uname],
                                    screen_size: params[:screen],
                                    lang_code: params[:lang_code]
                                    )
            user = User.create!
            device.uid = user.uid
            
            if device.save
              render_json(user, API::V1::Entities::UserBase)
            else
              render_error(4002, '注册失败!')
            end
          else
            render_json(device.user, API::V1::Entities::UserBase)
          end
          
        end # end create
        
      end # end account resource
      
      resource :user, desc: "用户接口" do
        
        desc "获取个人资料"
        params do
          requires :token, type: String, desc: "用户认证Token"
        end
        get :me do
          user = authenticate!
          render_json(user, API::V1::Entities::UserProfile)
        end # end get me
        
        desc "实名认证"
        params do
          requires :token, type: String, desc: "用户认证Token"
          requires :name,  type: String, desc: "姓名"
          requires :idcard,type: String, desc: "身份证号"
          optional :bank_no,type: String, desc: "银行卡号"
          optional :bank_mobile,type: String, desc: "银行预留手机"
        end
        post '/profile/authorize' do
          user = authenticate!
          
          if user.name && user.idcard
            return render_error(3000, '你已经实名认证过了')
          end
          
          code,msg = YoudunVerify.verify(params[:name], params[:idcard], params[:bank_no], params[:bank_mobile])
          if code != 0
            return render_error(code, msg)
          end
          
          user.name = params[:name]
          user.idcard = params[:idcard]
          user.bank_no = params[:bank_no]
          user.bank_mobile = params[:bank_mobile]
          user.bank_info = msg
          
          user.save!
          render_json(user, API::V1::Entities::UserProfile)
        end # end post auth
        
        desc "新增、修改个人资料"
        params do
          requires :token, type: String, desc: "用户认证Token"
          optional :pid,   type: Integer, desc: '个人资料ID'
          optional :idcard,type: String, desc: '身份证'
          optional :name,  type: String, desc: '名字'
          optional :sex,   type: String, desc: '性别'
          optional :birth,  type: String, desc: '生日'
          optional :phone,   type: String, desc: '电话'
          optional :is_student,type: Integer, desc: '是否在读，0或者1'
          optional :college,   type: String, desc: '学校'
          optional :specialty,  type: String, desc: '专业'
        end
        post :save_profile do
          user = authenticate!
          
          if params[:idcard]
            unless params[:idcard] =~ /\A\d{6}(18|19|20)?\d{2}(0[1-9]|1[012])(0[1-9]|[12]\d|3[01])\d{3}(\d|[xX])\z/
              return render_error(-1, '身份证不正确')
            end
          end
          
          pid = params[:pid]
          if pid.blank?
            # 新增
            if params[:idcard].blank? or params[:name].blank? or params[:sex].blank?
              return render_error(-1, '身份证、姓名、性别三个字段必填')
            end
            @profile = Profile.new(user_id: user.id, 
                            idcard: params[:idcard],
                            name: params[:name],
                            sex: params[:sex],
                            birth: params[:birth],
                            phone: params[:phone],
                            college: params[:college],
                            specialty: params[:specialty]
                            )
            if params[:is_student]
              @profile.is_student = params[:is_student] == 1 ? true : false
            end
            @profile.save!
            
          else
            # 修改
            @profile = user.profile
            @profile.idcard = params[:idcard] if params[:idcard]
            @profile.name = params[:name] if params[:name]
            @profile.sex = params[:sex] if params[:sex]
            @profile.phone = params[:phone] if params[:phone]
            @profile.birth = params[:birth] if params[:birth]
            @profile.college = params[:college] if params[:college]
            @profile.specialty = params[:specialty] if params[:specialty]
            @profile.is_student = (params[:is_student] == 1) if params[:is_student]
            @profile.save!
          end
          
          render_json(user, API::V1::Entities::UserProfile)
        end # end post save profile
        
        desc "交易明细"
        params do
          requires :token, type: String, desc: '用户TOKEN'
          use :pagination
        end
        get :trades do
          user = authenticate!
          @logs = TradeLog.where(user_id: user.uid).order('created_at desc')
          if params[:page]
            @logs = @logs.paginate page: params[:page], per_page: page_size
            total = @logs.total_entries
          else
            total = @logs.size
          end
          render_json(@logs, API::V1::Entities::TradeLog, {}, total)
        end # end get trades
        
        desc "用户版本检查"
        params do
          requires :bv,    type: String, desc: '当前App版本号'
          optional :token, type: String, desc: '用户登录TOKEN'
          optional :m,     type: String, desc: '设备名'
          optional :os,     type: String, desc: '设备平台, ios, android'
          optional :osv,    type: String, desc: '系统版本'
        end
        get :check_version do
          @app_version = AppVersion.where('version > ? and lower(os) = ?', params[:bv], params[:os].downcase)
            .where(opened: true).order('version desc').first
          if @app_version.blank?
            return render_error(4004, '没有新版本')
          end
          
          render_json(@app_version, API::V1::Entities::AppVersion)
        end # end check version
        
        desc "用户会话开始"
        params do
          requires :token,     type: String,  desc: '用户TOKEN'
          optional :type,      type: Integer, desc: '值为1或2或3；1表示APP Launch, 2表示 APP Resume'
          optional :loc,       type: String,  desc: '用户当前位置，值格式为：lng,lat'
          optional :network,   type: String,  desc: '用户当前的网络类型，例如：wifi, 3g, 4g'
          optional :version,   type: String,  desc: '当前客户端的版本号'
          optional :uuid,      type: String,  desc: '设备UUID'
          optional :os,        type: String,  desc: '设备系统'
          optional :osv,       type: String,  desc: '设备系统版本号'
          optional :model,     type: String,  desc: '设备型号，例如：iPhone 5s'
          optional :screen,    type: String, desc: '设备分辨率'
          optional :uname,     type: String, desc: '设备用户名字'
          optional :lang_code, type: String,  desc: '国家语言码，例如：zh_CN'
        end
        post '/session/begin' do
          user = authenticate!
          
          if params[:loc]
            loc = "POINT(#{params[:loc].gsub(',', ' ')})"
          else
            loc = nil
          end
          
          us = UserSession.create!(uid: user.uid, 
                              begin_time: Time.zone.now,
                              take_type: (params[:type] || 2).to_i,
                              location: loc,
                              app_version: params[:version],
                              ip: client_ip, 
                              network: params[:network],
                              uuid: params[:uuid],
                              os: params[:os],
                              os_version: params[:osv],
                              model: params[:model],
                              screen_size: params[:screen],
                              uname: params[:uname],
                              lang_code: params[:lang_code])
            
          @app_version = AppVersion.where('version > ? and lower(os) = ?', 
                                          params[:version], params[:os].downcase)
                                          .where(opened: true).order('version desc').first
          
          result = {
            session_id: us.uniq_id,
            config: {
              explore_url: SiteConfig.app_explore_url,
              kefu_url: SiteConfig.kefu_url,
              aboutus_url: SiteConfig.aboutus_url,
              faq_url: SiteConfig.faq_url,
              ad_blacklist: SiteConfig.ad_blacklist.split(',')
            }
          }
          
          if @app_version
            result = {
              session_id: us.uniq_id,
              config: {
                explore_url: SiteConfig.app_explore_url,
                kefu_url: SiteConfig.kefu_url,
                aboutus_url: SiteConfig.aboutus_url,
                faq_url: SiteConfig.faq_url,
                ad_blacklist: SiteConfig.ad_blacklist.split(','),
                ad_script: "var $el = $('a[id^=__a_z_]'); $el.hide();"
              },
              new_version: API::V1::Entities::AppVersion.represent(@app_version)
            }
          else
            result = {
              session_id: us.uniq_id,
              config: {
                explore_url: SiteConfig.app_explore_url,
                kefu_url: SiteConfig.kefu_url,
                aboutus_url: SiteConfig.aboutus_url,
                faq_url: SiteConfig.faq_url,
                ad_blacklist: SiteConfig.ad_blacklist.split(','),
                ad_script: "var $el = $('a[id^=__a_z_]'); $el.hide();"
              }
            }
          end
          
          { code: 0, message: 'ok', data: result }
        end # end post session begin
        
        desc "用户会话结束"
        params do
          requires :token,     type: String, desc: '用户TOKEN'
          requires :session_id,type: String, desc: '会话ID'
        end
        post '/session/end' do
          user = authenticate!
          
          us = UserSession.where(uid: user.uid, uniq_id: params[:session_id]).first
          us.end_time = Time.zone.now
          us.save!
          
          render_json_no_data
        end
        
        desc "获取VIP充值列表"
        params do
          requires :token, type: String, desc: '用户TOKEN'
        end
        get :vip_charge_list do
          user = authenticate!
          
          @vipcards = VipCard.where(actived_user_id: user.uid).where.not(actived_at: nil).order('actived_at desc')
          
          render_json(@vipcards, API::V1::Entities::VipCard)
        end # end get vip_charge_list
        
        desc "VIP激活"
        params do
          requires :token, type: String, desc: '用户TOKEN'
          requires :code,  type: String, desc: 'VIP卡号'
        end
        post '/vip/active' do
          user = authenticate!
          
          card = VipCard.find_by(code: params[:code])
          if card.blank?
            return render_error(4004, 'VIP卡不存在')
          end
          
          if not card.in_use
            return render_error(-1, 'VIP卡不可用')
          end
          
          if card.actived_at.present?
            return render_error(-1, 'VIP卡已经被激活')
          end
          
          user.active_vip_card!(card)
          
          render_json_no_data
          
        end # end vip active
        
        desc "获取已经抢到的/发出的红包"
        params do
          requires :token, type: String, desc: '用户TOKEN'
          requires :action, type: String, desc: '获取跟用户相关的红包，值为taked或者sent'
          optional :year, type: String, desc: '取某一年的数据'
        end
        get '/:action/redpacks' do
          user = authenticate!
          
          unless %w(taked sent).include? params[:action]
            return render_error(-1, '不正确的action参数，值只能为taked或sent')
          end
          
          user_json = {
            id: user.uid,
            nickname: user.format_nickname,
            avatar: user.format_avatar_url
          }
          
          if params[:action] == 'taked'
            redpack_logs = RedpackSendLog.where(user_id: user.uid).order('created_at desc')
            if params[:year]
              redpack_logs = redpack_logs.where('extract(year from created_at) = ?', params[:year] )
            end
            
            # 获取抢到的现金红包
            cash_redpack_logs = RedpackSendLog.joins('inner join redpacks on redpacks.uniq_id = redpack_send_logs.redpack_id').where('redpacks.use_type = 1').where(user_id: user.uid)
            no_cash_redpack_logs = RedpackSendLog.joins('inner join redpacks on redpacks.uniq_id = redpack_send_logs.redpack_id').where('redpacks.use_type = 2').where(user_id: user.uid)
            
            if params[:year]
              cash_redpack_logs = cash_redpack_logs.where('extract(year from redpack_send_logs.created_at) = ?', params[:year])    
              no_cash_redpack_logs = cash_redpack_logs.where('extract(year from redpack_send_logs.created_at) = ?', params[:year])
            end
            
            cash_redpack_money = cash_redpack_logs.map { |log| log.money }.sum
            cash_redpack_count = cash_redpack_logs.size
            
            no_cash_redpack_money = no_cash_redpack_logs.map { |log| log.money }.sum
            no_cash_redpack_count = no_cash_redpack_logs.size
            
            user_json['c_money'] = '%.2f' % (cash_redpack_money / 100.00)
            user_json['c_count'] = cash_redpack_count
            user_json['nc_money'] = '%.2f' % (no_cash_redpack_money / 100.00)
            user_json['nc_count'] = no_cash_redpack_count
            
            { code: 0, message: 'ok', data: { 
              user: user_json, 
              list: API::V1::Entities::SimpleRedpackSendLog.represent(redpack_logs) 
              } }
            # render_json(redpack_logs, API::V1::Entities::RedpackSendLogDetail)
          else
            redpacks = Redpack.where(owner_id: user.uid).order('created_at desc')
            
            if params[:year]
              redpacks = redpacks.where('extract(year from created_at) = ?', params[:year] )
            end
            
            cash_redpacks = redpacks.where(use_type: 1)
            no_cash_redpacks = redpacks.where(use_type: 2)
            
            cash_money = cash_redpacks.map { |r| r.total_money }.sum
            cash_count = cash_redpacks.size
            
            no_cash_money = no_cash_redpacks.map { |r| r.total_money }.sum
            no_cash_count = no_cash_redpacks.size
            
            user_json['c_money'] = '%.2f' % (cash_money / 100.00)
            user_json['c_count'] = cash_count
            user_json['nc_money'] = '%.2f' % (no_cash_money / 100.00)
            user_json['nc_count'] = no_cash_count
            
            { code: 0, message: 'ok', data: { 
              user: user_json, 
              list: API::V1::Entities::EditableRedpack.represent(redpacks) 
              } }
              
            # render_json(redpacks, API::V1::Entities::Redpack)
          end
        end # end get redpackes
        
        desc "获取消费红包抵扣记录"
        params do
          requires :token, type: String, desc: '用户TOKEN'
          requires :action, type: String, desc: '获取跟用户相关的红包，值为confirmed(我抵扣别人的)或者confirming(别人抵扣我的)'
        end 
        get '/:action/hb_consumes' do
          user = authenticate!
          
          unless %w(confirmed confirming).include? params[:action]
            return render_error(-1, '不正确的action参数，值只能为confirmed或confirming')
          end
          
          if params[:action] == 'confirmed'
            @consumes = RedpackConsume.where(user_id: user.uid).order('created_at desc')
          else
            @consumes = RedpackConsume.where(owner_id: user.uid).order('created_at desc')
          end
          
          total_money = @consumes.map { |c| c.money }.sum
          
          { code: 0, message: 'ok', data: {
            total_money: '%.2f' % (total_money.to_f / 100.00),
            list: API::V1::Entities::RedpackConsume.represent(@consumes, { action: params[:action] })
          } }
          
        end # end get hb_consumes
        
      end # end user resource
      
    end 
  end
end