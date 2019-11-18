# require 'rest-client'
class Front::SalariesController < Front::ApplicationController
  # skip_before_filter :verify_authenticity_token, :only => [:wx_notify]
  before_filter :require_user
  before_filter :check_user_profile
  
  def new
    @salary = Salary.new
  end
  
  def create
    @salary = Salary.new(salary_params)
    @salary.user_id = current_user.id
    if @salary.save
      current_user.current_pay_name = @salary.pay_name
      current_user.current_pay_account = @salary.pay_account
      current_user.save
      
      redirect_to front_apply_success_path
    else
      render :new
    end
  end
  
  def apply_success
    
  end
  
  private
  def salary_params
    params.require(:salary).permit(:project_id, :money, :pay_name, :pay_account)
  end
  
  def check_user_profile
    if current_user.profile.blank?
      redirect_to new_front_profile_path
    end
  end
  
end
