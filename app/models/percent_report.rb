require Rails.root.join('lib', 'nerd_repository')

class PercentReport
  
  def initialize(access_token)
    @nerd_repository = NerdRepository.new(access_token)
  end
  
  def total_nerds
    @nerd_repository.all.count
  end
  
  def my_hire_date
    @nerd_repository.me["hire_date"]
  end
  
  def percent_newer_than_me
    ((total_nerds_with_hire_dates.reject { |nerd|
      nerd["hire_date"] < Date.parse(my_hire_date)
    }.count.to_f / total_nerds_with_hire_dates.count.to_f) * 100).round(2)
  end
  
  private
  def total_nerds_with_hire_dates
    @total_nerds_with_hire_dates ||= @nerd_repository.all.reject { |nerd| nerd["hire_date"].blank? }
  end
end