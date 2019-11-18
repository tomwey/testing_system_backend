# coding: utf-8
require 'rest-client'
class YoudunVerify
  def self.verify(name, idcard, bank_no, bank_mobile)
    return -1,"参数错误" if name.blank? || idcard.blank? || bank_no.blank? || bank_mobile.blank?
    params = {
      id_name: name,
      id_no: idcard,
      bank_card_no: bank_no,
      mobile: bank_mobile,
      req_type: '02'
    }
    sign = sign_params(params)
    api_url = "https://api4.udcredit.com/dsp-front/4.1/dsp-front/default/pubkey/#{SiteConfig.yd_pub_key}/product_code/#{SiteConfig.yd_product_code}/out_order_id/#{Time.zone.now.to_i}/signature/#{sign}"
    # puts api_url
    res = RestClient.post api_url, params.to_json, {content_type: :json, accept: :json}
    # puts res
    result = JSON.parse(res)
    if result && result['body']
      body = result['body']
      if body['status'] == '1'
        return 0,"#{body['province']},#{body['city']},#{body['bank_name']},#{body['card_type']},#{body['card_name']}"
      else
        return 4000,body['message']
      end
    else
      return 5000,"请求验证出错"
    end
  end
  
  def self.sign_params(params)
    string = params.to_json + "|" + SiteConfig.yd_secret_key
    Digest::MD5.hexdigest(string).upcase
  end
end