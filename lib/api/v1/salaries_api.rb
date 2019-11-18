# require 'rest-client'
module API
  module V1
    class SalariesAPI < Grape::API
      
      helpers API::SharedParams
      
      resource :projects, desc: '项目相关' do
        desc '获取项目列表'
        params do
          optional :token,   type: String, desc: '认证TOKEN'
          optional :keyword, type: String, desc: '关键字'
        end
        get do
          @projects = Project.where(opened: true).order('sort desc, id desc')
          if params[:keyword]
            @projects = @projects.where('uniq_id like :kw or title like :kw', kw: "%#{params[:keyword]}%")
          end
          
          # user = User.find_by(private_token: params[:token])
          # if user.present?
          #   proj_ids = Salary.where(user_id: user.id).pluck(:project_id)
          #   @projects = @projects.where.not(id: proj_ids)
          # end
          
          render_json(@projects, API::V1::Entities::Project)
          
        end # end get
      end # end resource projects
      
      resource :salaries, desc: '工资相关' do
        desc "创建工资申请"
        params do
          requires :token,   type: String, desc: '认证TOKEN'
          requires :proj_id, type: String, desc: '项目ID'
          requires :money,   type: Float, desc: '工资金额'
          optional :pay_name,type: String, desc: '支付宝姓名'
          optional :pay_account, type: String, desc: '支付宝账号'
          optional :selected_days, type: String, desc: '结算日期'
        end
        post :create do
          user = authenticate!
          @project = Project.find_by(uniq_id: params[:proj_id])
          if @project.blank? or !@project.opened
            return render_error(4004, '兼职不存在')
          end
          
          if params[:money] <= 0.0
            return render_error(-1, '工资金额必须大于0元')
          end
          
          count = Salary.where(project_id: @project.id, user_id: user.id).count
          if count > 0
            return render_error(3001, '您已经提交过工资申请')
          end
          
          pay_name = params[:pay_name] || user.current_pay_name
          pay_account = params[:pay_account] || user.current_pay_account
          
          if pay_name.blank? or pay_account.blank?
            return render_error(-1, '支付宝账号不能为空')
          end
          
          # if @project.begin_date.present?
          #   if params[:selected_days].blank?
          #     return render_error(-1, '结算日期不能为空')
          #   end
          # end
          
          settle_times = params[:selected_days]
          settle_times_score = Salary.calc_score(settle_times)
          
          @salary = Salary.create!(project_id: @project.id, 
                                   user_id: user.id, 
                                   money: params[:money], 
                                   pay_name: pay_name, 
                                   pay_account: pay_account,
                                   settle_times: settle_times,
                                   settle_times_score: settle_times_score
                                   )
          render_json(@salary, API::V1::Entities::Salary)
          
        end # end post
        
        desc '获取工资申请记录'
        params do 
          requires :token, type: String, desc: '认证TOKEN'
          optional :state, type: Integer,desc: '数据类型，0 待发放 1 已发放'
          use :pagination
        end
        get :list do
          user = authenticate!
          @salaries = Salary.where(user_id: user.id).order('id desc')
          
          if params[:state]
            state = params[:state].to_i
            if state == 0
              @salaries = @salaries.where(payed_at: nil)
            elsif state == 1
              @salaries = @salaries.where.not(payed_at: nil)
            end
          end
          
          # 分页
          if params[:page]
            @salaries = @salaries.paginate page: params[:page], per_page: page_size
            total = @salaries.total_entries
          else
            total = @salaries.size
          end
          
          render_json(@salaries, API::V1::Entities::Salary)
        end # end get list
      end # end resource
      
    end
  end
end