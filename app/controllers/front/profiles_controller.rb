# require 'rest-client'
class Front::ProfilesController < Front::ApplicationController
  before_filter :require_user
  
  before_filter :check_user_profile
  
  def new
    @profile = Profile.new
  end
  
  def create
    @profile = Profile.new(profile_params)
    @profile.user_id = current_user.id
    if @profile.save
      redirect_to new_front_salary_path
    else
      render :new
    end
  end
  
  private
  def profile_params
    params.require(:profile).permit(:name, :sex, :birth, :idcard, :phone, :is_student, :college, :specialty)
  end
  def check_user_profile
    if current_user.profile.present?
      redirect_to new_front_salary_path
    end
  end
  
end
