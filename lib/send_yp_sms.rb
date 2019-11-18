require 'rest-client'
class SendYpSms
  def self.send(mobile, code)
    tpl = SiteConfig.yp_sms_tpl
    text = tpl.gsub('#code#', code)
    resp = RestClient.post("https://sms.yunpian.com/v2/sms/single_send.json", "apikey=#{SiteConfig.yp_sms_api_key}&mobile=#{mobile}&text=#{text}")
    result = JSON.parse(resp)
    if result['code'] == 0
      return ""
    else
      return result['msg']
    end
  end
end