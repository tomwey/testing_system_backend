class PromoController < ApplicationController
  layout 'promo'
  
  def poster
    @poster = PromoPoster.where(opened: true, uniq_id: params[:id]).first
    
  end
  
  def channel
    @channel = Channel.where(opened: true, uniq_id: params[:id]).first
    # if @channel.blank?
    #   render text: '推广渠道不存在', status: 404
    #   return
    # end
    @poster = @channel.promo_poster
    
  end
end
