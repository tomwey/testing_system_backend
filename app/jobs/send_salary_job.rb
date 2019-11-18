class SendSalaryJob < ActiveJob::Base
  queue_as :scheduled_jobs

  def perform(project_id)
    
    @project = Project.find_by(id: project_id)
    return if @project.blank? or !@project.opened
    
    @salaries = @project.salaries.where(payed_at: nil, state: 'approved')
    @salaries.each do |salary|
      salary.confirm_pay!
    end
    
  end
  
end
