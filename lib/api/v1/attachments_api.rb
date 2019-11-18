require 'qiniu'
require 'base64'

module API
  module V1
    class AttachmentsAPI < Grape::API
      
      resource :videos, desc: '视频相关接口' do
        desc "获取视频播放密钥"
        params do
          requires :atype, type: String, desc: '账号类型'
          requires :token, type: String, desc: '认证TOKEN'
          requires :vid,   type: String, desc: '视频ID'
        end
        get '/:vid/play_key' do
          begin
            klass = params[:atype].classify.constantize
          rescue => ex
            return render_error(5000, '不存在的资源')
          end
          
          obj = klass.find_by(private_token: params[:token])
          if obj.blank? or obj.deleted_at.present?
            return render_error(4004, '账号不存在或未登录')
          end
          
          vid = Video.find_by(id: params[:vid])
          if vid.blank? or vid.deleted_at.present? or !vid.opened
            return render_error(4004, '视频不存在或还未上架')
          end
          
          { code: 0, message: 'ok', data: { key: vid.sec_key } }
        end # end get play_key
        
      end # end resource
      resource :assets, desc: '附件相关接口' do
        desc "获取七牛上传信息"
        params do
          optional :token,   type: String,  desc: '认证TOKEN'
          requires :jm_type, type: Integer, desc: '是否需要加密视频, 0 表示不加密，1 表示mp4加密'
        end
        get :qn_up_info do
          unless [0, 1].include? params[:jm_type]
            return render_error(-1, '不正确的jm_type参数')
          end
          
          bucket = "#{SiteConfig.qiniu_bucket}"
          filename = "#{SecureRandom.uuid.gsub('-','')}.mp4"
          key = "uploads/video/" + filename
          
          put_policy = Qiniu::Auth::PutPolicy.new(
              bucket,      # 存储空间
              key,     # 最终资源名，可省略，即缺省为“创建”语义，设置为nil为普通上传 
              3600    #token过期时间，默认为3600s
          )
          
          # hls_key = Base64.urlsafe_encode64(SiteConfig.qiniu_aes_key)
          # hls_key_url = Base64.urlsafe_encode64('http://b.tgs.91coding.cn/hls_key')
          
          if params[:jm_type] == 1 # 需要进行mp4加密
            # 转码时使用的队列名称。
            pipeline = 'video-aesencrpt' # 设定自己账号下的队列名称
            # fops = "avthumb/m3u8/noDomain/1/vb/640k/hlsKey/#{hls_key}/hlsKeyUrl/#{hls_key_url}"
            sec_key = SecureRandom.random_number(100000..100000000).to_s
            saveas_key = Qiniu::Utils.urlsafe_base64_encode("#{bucket}:uploads/video/#{filename}")
            filename = sec_key + ':' + filename 
            com_key = Base64.urlsafe_encode64(sec_key)
            file_key = Base64.urlsafe_encode64(SecureRandom.random_number(1000..100000).to_s)
            fops = "avthumb/mp4/vcodec/copy/acodec/copy/drmComKey/#{com_key}/drmFileKey/#{file_key}"
            fops = fops +'|saveas/' + saveas_key
          
            put_policy.persistent_ops = fops
            put_policy.persistent_pipeline = pipeline
          end
          
          uptoken = Qiniu::Auth.generate_uptoken(put_policy)
          
          { code: 0, message: 'ok', data: { key: key, filename: filename, token: uptoken } }
        end # end get qiniu upload token
        desc "单附件上传"
        params do
          optional :token, type: String, desc: '认证TOKEN'
          requires :file, type: Rack::Multipart::UploadedFile, desc: '附件文件数据'
          optional :f, type: Integer, desc: '编辑器上传'
        end
        post do
          asset = Attachment.new(data: params[:file], owner: Account.find_by(private_token: params[:token]))
          if asset.save
            status 200
            if params[:f] == 9
              { link: asset.data.url }
            else
              render_json(asset, API::V1::Entities::Attachment)
            end
            
          else
            status 200
            if params[:f] == 9
              {link: '', errors: asset.errors.full_messages}
            else
              render_error(5000, asset.errors.full_messages)
            end
          end
        end # end post upload
        
        desc "多附件上传"
        params do
          optional :token, type: String, desc: '认证TOKEN'
          requires :files,   type: Array,  desc: "附件数组" do
            requires :file, type: Rack::Multipart::UploadedFile, desc: '附件文件数据'
          end
        end
        post :multi_upload do
          return render_error(5000, '至少需要1个附件') if params[:files].empty?
          
          assets = []
          params[:files].each do |param|
            asset = Attachment.create(data: param[:file], owner: Account.find_by(private_token: params[:token]))
            assets << asset if asset.present?
          end
          
          render_json(assets, API::V1::Entities::Attachment)
          
        end # end post upload
        
        desc "查询附件"
        params do
          optional :token, type: String, desc: 'TOKEN'
          requires :id, type: String, desc: '多个附件ID用英文逗号分隔'
          optional :is_pv, type: Integer, desc: '是否是保利威'
        end
        get '/:id' do
          # user = authenticate!
          ids = params[:id].split(',')
          assets = Attachment.where(id: ids)
          render_json(assets, API::V1::Entities::Attachment)
        end # end get
        
      end # end resource
      
    end
  end
end