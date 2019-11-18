require 'rest-client'
require 'base64'
require 'cgi'
require 'openssl'

class SendAliSms
  def self.send(mobile, text)
    params = {
      AccessKeyId: SiteConfig.ali_sms_access_key_id,
      Timestamp: Time.zone.now.utc.strftime('%Y-%m-%dT%H:%M:%SZ'),
      SignatureMethod: 'HMAC-SHA1',
      SignatureVersion: '1.0',
      SignatureNonce: SecureRandom.uuid,
      Action: 'SendSms',
      Version: '2017-05-25',
      RegionId: 'cn-hangzhou',
      PhoneNumbers: mobile,
      SignName: SiteConfig.ali_sms_sign_name,
      TemplateCode: SiteConfig.ali_sms_template_code,
      TemplateParam: "{\"code\":\"#{text}\"}"
    }
    # puts text
    
    sign = sign_params(params)
    # puts sign
    
    params["Signature"] = sign
    # puts params
    query_string = params.map { |k,v| "#{k}=#{CGI.escape(v)}" }.join('&')
    url = 'http://dysmsapi.aliyuncs.com/?' + query_string
    # puts url
    resp = RestClient.get url
    result = Hash.from_xml(resp)
    puts result
    
    if result["SendSmsResponse"]
      if result["SendSmsResponse"]["Code"] == 'OK'
        return ""
      else
        return result["SendSmsResponse"]["Message"]
      end
    else
      return "发送短信失败"
    end
  end
  
  def self.sign_params(params)
    arr = params.sort
    hash = Hash[*arr.flatten]
    string = hash.delete_if { |k,v| v.blank? }.map { |k,v| "#{k}=#{CGI.escape(v)}" }.join('&')
    # puts string
    string = "GET" + "&%2F&" + CGI.escape(string)
    # puts string
    key = SiteConfig.ali_sms_access_key_secret + '&'
    Base64.encode64("#{OpenSSL::HMAC.digest('sha1',key, string)}").delete("\n").delete("\r")
  end
end

# SendAliSms.send('18048553687', '3090')