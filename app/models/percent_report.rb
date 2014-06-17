require Rails.root.join('lib', 'nerd_repository')

class PercentReport

  def initialize(access_token)
    @nerd_repository = NerdRepository.new(access_token)
  end

  def total_nerds_count
    Rails.cache.fetch('total_nerds_count') do
      @nerd_repository.all.count
    end
  end

  def total_active_nerds_count
    Rails.cache.fetch('total_active_nerds_count') do
      @nerd_repository.active.count
    end
  end

  def my_hire_date
    @nerd_repository.me["hire_date"]
  end

  def percent_newer_than_me
    ((total_nerds_with_hire_dates.reject { |nerd|
      nerd["hire_date"] < Date.parse(my_hire_date)
    }.count.to_f / total_nerds_with_hire_dates.count.to_f) * 100).round(2)
  end

  def active_buckets_and_nerd_counts_js
    Rails.cache.fetch('active_buckets_and_nerd_counts_js') do
      buckets = []
      total_nerds_with_hire_dates.each do |nerd|
        (nerd["hire_date"]..Date.today).each do |some_day|
          buckets[days_since_big_nerd_epoch(some_day)] ||= 0
          buckets[days_since_big_nerd_epoch(some_day)] = buckets[days_since_big_nerd_epoch(some_day)] + 1
        end
      end
      format_for_epoch_js(buckets)
    end
  end

  def inactive_buckets_and_nerd_counts_js
    Rails.cache.fetch('inactive_buckets_and_nerd_counts_js') do
      buckets = []
      total_nerds_with_hire_dates_only_inactive.each do |nerd|
        (nerd["hire_date"]..Date.today).each do |some_day|
          buckets[days_since_big_nerd_epoch(some_day)] ||= 0
          buckets[days_since_big_nerd_epoch(some_day)] = buckets[days_since_big_nerd_epoch(some_day)] + 1
        end
      end
      format_for_epoch_js(buckets)
    end
  end

  def earliest_hire_date
    Rails.cache.fetch('earliest_hire_date') do
      min_hire_date = Date.parse(my_hire_date)
      total_nerds_with_hire_dates_including_inactive.each do |nerd|
        min_hire_date = nerd["hire_date"] if nerd["hire_date"] < min_hire_date
      end
      min_hire_date
    end
  end

  private
  def total_nerds_with_hire_dates
    Rails.cache.fetch('total_nerds_with_hire_dates') do
      @nerd_repository.active.reject {
        |nerd| nerd["hire_date"].blank?
      }
    end
  end

  def total_nerds_with_hire_dates_including_inactive
    Rails.cache.fetch('total_nerds_with_hire_dates_including_inactive') do
      @nerd_repository.all.reject {
        |nerd| nerd["hire_date"].blank?
      }
    end
  end

  def total_nerds_with_hire_dates_only_inactive
    Rails.cache.fetch('total_nerds_with_hire_dates_only_inactive') do
      @nerd_repository.all.reject {
        |nerd| nerd["hire_date"].blank? || (nerd["active"] == true)
      }
    end
  end

  def days_since_big_nerd_epoch(some_day)
    some_day - earliest_hire_date
  end

  def format_for_epoch_js(buckets)
    representations = []
    buckets.each_with_index { |index, entry|
      representations.push "{x: #{entry}, y: #{index || 0}}"
    }
    representations.join(',')
  end
end
