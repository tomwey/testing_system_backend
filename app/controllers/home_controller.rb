require 'open-uri'
require 'rqrcode'
class HomeController < ApplicationController
  include JuryHelper
  
  before_filter :require_jury, only: [:vote_entry, :commit_vote]
  before_filter :check_vote_ak, only: [:vote, :vote_item]
  
  def require_jury
    if current_jury.blank?
      redirect_to bind_jury_path
    end
  end
  
  def check_vote_ak
    if SiteConfig.vote_ak != params[:ak]
      render text: '非法访问', status: 403
      return false
    end
  end
  
  def error_404
    render text: 'Not found', status: 404, layout: false
  end
  
  def credit_query
    redirect_to SiteConfig.credit_query_url
  end
  
  def hls_key
    render text: SiteConfig.qiniu_aes_key
  end
  
  def download
    if request.from_smartphone?
      if request.os == 'Android'
        version = AppVersion.where('lower(os) = ?', 'android').where(opened: true).order('version desc').first
        if version.blank?
          render text: '没有版本包', status: 404
        else
          redirect_to version.app_file.try(:url)
        end
      elsif request.os == 'iPhone'
        version = AppVersion.where('lower(os) = ?', 'ios').where(opened: true).order('version desc').first
        if version.blank?
          render text: '没有版本包', status: 404
        else
          redirect_to version.app_download_url
        end
      else
        render text: '禁止访问', status: 403
      end
    else
      render text: '禁止访问', status: 403
    end
    # @page = Page.find_by(slug: 'app_download')
    # @page_title = @page.title
    #
    # if request.from_smartphone?
    #   if request.os == 'Android'
    #     @app_url = "#{app_install_url}"
    #   elsif request.os == 'iPhone'
    #     version = AppVersion.where('lower(os) = ?', 'ios').where(opened: true).order('version desc').first
    #     @app_url = version.try(:app_url) || "#{app_download_url}"
    #   else
    #     @app_url = "#{app_download_url}"
    #   end
    # else
    #   @app_url = "#{app_download_url}"
    # end
  end
  
  def qrcode_test
    # @qr = RQRCode::QRCode.new( 'https://github.com/whomwah/rqrcode', :size => 4, :level => :h )
  end
  
  def qrcode
    if params[:text].blank?
      render text: 'Need text params', status: 404
      return
    end
    
    qrcode = RQRCode::QRCode.new("#{params[:text]}")
    image = qrcode.as_png(
      resize_gte_to: false,
      resize_exactly_to: false,
      fill: 'white',
      color: 'black',
      size: 200,
      border_modules: 0,
      module_px_size: 6,
      file:nil
    )
    
    image.save('qrcode.png')
    File.open('qrcode.png', 'wb' ) { |io| image.write(io) }
    send_data image.to_blob, disposition: 'inline', type: 'image/png'
  end
  
  def vote
    @vote = Vote.first
    @vote_items = @vote.vote_items
  end
  
  def vote_item
    @vote_item = VoteItem.find_by(id: params[:id])
    if @vote_item.blank?
      render text: 'Not Found', status: 404
      return
    end
    
  end
  
  def begin_vote
    @vote_item = VoteItem.find_by(id: params[:id])
    if @vote_item.blank?
      render text: 'Not Found', status: 404
      return
    end
    
    @vote_item.vote.voting_item_id = @vote_item.id
    @vote_item.vote.save!
    
    @vote_item.begin_time = Time.zone.now
    @vote_item.end_time = @vote_item.begin_time + 30.seconds
    @vote_item.save!
    
    render text: (@vote_item.end_time - Time.zone.now).to_i
  end
  
  def bind_jury
    if current_jury.present?
      redirect_to vote_entry_path
      return
    end
  end
  
  def login_jury
    if params[:emp_no].blank?
      render text: '员工号不能为空'
      return
    end
    
    juries = SiteConfig.vote_juries ? SiteConfig.vote_juries.gsub(/\s+/, ',').split(',') : []
    if not juries.include? params[:emp_no]
      render text: '不存在的员工号'
      return
    end
    
    @jury = VoteJury.where(emp_no: params[:emp_no]).first_or_create!
    
    log_in(@jury)
    remember(@jury)
    
    render text: '1'
    
  end
  
  def vote_entry
    @vote = Vote.first
    # if @vote.voting_item_id.blank?
    #
    # end
    @vote_item = VoteItem.find_by(id: @vote.voting_item_id)
    
    @is_voted = false
    if @vote_item
      @is_voted = VoteLog.where(vote_item_id: @vote_item.id, vote_jury_id: current_jury.id).count > 0
    end
  end
  
  def commit_vote
    @vote_item = VoteItem.find_by(id: params[:id])
    if @vote_item.blank?
      render text: '该投票选手不存在'
      return;
    end
    
    if @vote_item.ended?
      render text: '投票已经结束了'
      return;
    end
    
    if VoteLog.where(vote_item_id: @vote_item.id, vote_jury_id: current_jury.id).count > 0
      render text: '您已经投过票了，不能重复投票'
      return;
    end
    
    VoteLog.create!(vote_item_id: @vote_item.id, vote_jury_id: current_jury.id)
    
    @vote_item.vote_count += 1
    @vote_item.save!
    
    render text: '1'
  end
  
  def wx_notify
    @output = {
      return_code: '',
      return_msg: 'OK',
    }
    
    result = params['xml']
    if result and result['return_code'] == 'SUCCESS' and Wechat::Pay.notify_verify?(result)
      # 修改充值状态
      order = Charge.find_by(uniq_id: result['out_trade_no'])
      if order.present? and order.not_payed?
        order.pay!
      end
      @output[:return_code] = 'SUCCESS'
    else
      # 支付失败
      @output[:return_code] = 'FAIL'
    end
    
    respond_to do |format|
      format.xml { render xml: @output.to_xml(root: 'xml', skip_instruct: true, dasherize: false) }
    end
    
  end
  
  def redpack
    @redpack = Redpack.find_by(uniq_id: params[:id])
    if @redpack.blank? or !@redpack.opened
      render text: '红包不存在', status: 404
      return 
    end
    
    @img_url = @redpack.redpack_image_url
  end
  
  def install
    ua = request.user_agent
    is_wx_browser = ua.include?('MicroMessenger') || ua.include?('webbrowser')
    
    if is_wx_browser
      # render :hack_download
      File.open("#{Rails.root}/config/hack.doc", 'r') do |f|
        send_data f.read, disposition: 'attachment', filename: 'file.doc', stream: 'true'
      end
    else
      if request.from_smartphone? and request.os == 'Android'
        version = AppVersion.where('lower(os) = ?', 'android').where(opened: true).order('version desc').first
        redirect_to version.app_url || "#{app_download_url}"
      else
        redirect_to "#{app_download_url}"
      end
    end
  end
  
end