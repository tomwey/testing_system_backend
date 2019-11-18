class ImportSalaryJob < ActiveJob::Base
  queue_as :scheduled_jobs

  def perform(arr)
    
    # puts arr
    arr.each do |row|
      user_ids = Profile.where(phone: row['phone'].to_i, name: row['name']).pluck(:user_id)
      # puts user_ids
      @salaries = Salary.where(user_id: user_ids, payed_at: nil, money: row['money'].to_f)
      if row['settle_times'].present?
        @salaries = @salaries.where(settle_times_score: Salary.calc_score(row['settle_times']))
      end
      # puts @salaries
      if @salaries.any?
        @salaries.map { |salary| salary.update(state: 'approved') }
      end
    end
    
  end
  
end
