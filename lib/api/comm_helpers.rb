require 'rest-client'
module API
  module CommHelpers
    # 获取服务器session
    def session
      env[Rack::Session::Abstract::ENV_SESSION_KEY]
    end # end session method
    
    # 获取客户端ip
    def client_ip
      env['action_dispatch.remote_ip'].to_s
    end
    
    # 根据客户端ip获取客户的位置
    def client_loc_from_ip
      res = RestClient.get "https://apis.map.qq.com/ws/location/v1/ip?ip=#{client_ip}&key=EJZBZ-VCM34-QJ4UU-XUWNV-3G2HJ-DWBNJ"
      json = JSON.parse(res)
      if json['status'] == 0
        if json['result'] && json['result']['location']
          return json['result']['location']['lng'],json['result']['location']['lat']
        else
          return nil
        end
      else
        return nil
      end
    end
  
    # 最大分页大小
    def max_page_size
      100
    end # end max_page_size method
  
    # 默认分页大小
    def default_page_size
      15
    end # end default_page_size method
  
    # 分页大小
    def page_size
      size = params[:size].to_i
      size = size.zero? ? default_page_size : size
      [size, max_page_size].min
    end # end page_size method
  
    # 1.格式化输出带结果数据的json
    def render_json(target, grape_entity, opts = {}, total = 0)
      return { code: 0, message: 'ok', data: {} } if target.nil?
      return { code: 0, message: 'ok', data: [] } if target.is_a?(Array) and target.blank?
      
      present target, :with => grape_entity, :opts => opts
      
      if total > 0
        body( { code: 0, message: 'ok', total: total, data: body } )
      else
        body( { code: 0, message: 'ok', data: body } )
      end
      
    end # end render_json method
  
    # 2.格式化输出错误
    def render_error(error_code, message)
      { code: error_code, message: message }
    end # end render_error method
  
    # 3.格式输出无数据的json
    def render_json_no_data
      render_error(0, 'ok')
    end # end render_json_no_data method
  
    # 当前登录用户
    def current_user
      token = params[:token]
      @current_user ||= User.where(private_token: token).first
    end # end current_user
  
    # 认证用户
    def authenticate!
      error!({"code" => 401, "message" => "用户未登录"}, 200) unless current_user
      error!({"code" => -10, "message" => "您的账号已经被禁用"}, 200) unless current_user.verified
    
      # 返回当前用户
      current_user
    end # end authenticate!
    
    # 当前登录账号
    def current_account
      token = params[:token]
      @current_account ||= Account.where(private_token: token).first
    end # end current_user
  
    # 认证用户
    def authenticate_account!
      error!({"code" => 401, "message" => "账号未登录"}, 200) unless current_account
      error!({"code" => -10, "message" => "您的账号已经被禁用"}, 200) unless current_account.opened
      
      msg = check_merch_state(current_account)        
      error!({"code" => -10, "message" => msg}, 200) if msg.present?
    
      # 返回当前用户
      current_account
    end # end authenticate!
    
    # 判断权限
    def authorize_for!(resource_class, actions)
      account = authenticate_account!
      error!({"code" => -20, "message" => "暂无此权限"}, 200) unless account.can?(resource_class, actions)
      account
    end
    
    # 检查账号主体状态
    def check_merch_state(account)
      merch = account.company
      if merch.blank? or merch.deleted_at.present?
        return "机构不存在"
      end
      
      if !merch.opened
        return "系统已被禁用"
      end
      
      merch = merch.parent || merch
      
      if merch.vip_expired_at.blank?
        return "系统还未开通"
      end
      
      if merch.vip_expired_at.end_of_day < Time.zone.now
        return "系统使用已到期"
      end
      
      return ""
    end
  
    # 手机号验证
    def check_mobile(mobile)
      return false if mobile.blank?
      return false if mobile.length != 11
      mobile =~ /\A1[3|4|5|6|8|7|9][0-9]\d{4,8}\z/
    end # end check_mobile
  end
end