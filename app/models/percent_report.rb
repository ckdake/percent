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
    Date.parse(@nerd_repository.me["hire_date"])
  end

  def percent_newer_than_me
    ((current_nerds_with_hire_date.reject { |nerd|
      nerd["hire_date"] < my_hire_date
    }.count.to_f / current_nerds_with_hire_date.count.to_f) * 100).round(2)
  end

  def current_nerds_buckets_js
    Rails.cache.fetch('current_nerds_buckets_js') do
      buckets = []
      current_nerds_with_hire_date.each { |nerd|
        (nerd["hire_date"]..Date.today).each do |some_day|
          buckets[days_since_big_nerd_epoch(some_day)] ||= 0
          buckets[days_since_big_nerd_epoch(some_day)] = buckets[days_since_big_nerd_epoch(some_day)] + 1
        end
      }
      format_for_epoch_js(buckets)
    end
  end

  def all_nerds_buckets_js
    Rails.cache.fetch('all_nerds_buckets_js') do
      buckets = []
      nerds_with_hire_date.each { |nerd|
        nerd["end_date"] = Date.today if nerd["end_date"].blank?
        (nerd["hire_date"]..nerd["end_date"]).each do |some_day|
          buckets[days_since_big_nerd_epoch(some_day)] ||= 0
          buckets[days_since_big_nerd_epoch(some_day)] = buckets[days_since_big_nerd_epoch(some_day)] + 1
        end
      }
      format_for_epoch_js(buckets)
    end
  end

  def inactive_nerds_buckets_js
    Rails.cache.fetch('inactive_nerds_buckets_js') do
      buckets = []
      inactive_nerds_with_hire_date.each { |nerd|
        (nerd["hire_date"]..Date.today).each do |some_day|
          buckets[days_since_big_nerd_epoch(some_day)] ||= 0
          buckets[days_since_big_nerd_epoch(some_day)] = buckets[days_since_big_nerd_epoch(some_day)] + 1
        end
      }
      format_for_epoch_js(buckets)
    end
  end

  def earliest_hire_date
    @earliest_hire_date ||= Rails.cache.fetch('earliest_hire_date') do
      min_hire_date = my_hire_date
      nerds.each do |nerd|
        min_hire_date = nerd["hire_date"] if !nerd["hire_date"].blank? && nerd["hire_date"] < min_hire_date
      end
      min_hire_date
    end
  end

  private
  def nerds
    Rails.cache.fetch('nerds') do
      @nerd_repository.all
    end
  end

  def nerds_with_hire_date
    nerds.select { |nerd| nerd["hire_date"].present? }
  end

  def current_nerds
    nerds.select { |nerd| nerd["active"] == true }
  end

  def inactive_nerds
    nerds.select { |nerd| nerd["active"] == false }
  end

  def inactive_nerds_with_hire_date
    inactive_nerds.select { |nerd| nerd["hire_date"].present? }
  end

  def current_nerds_with_hire_date
    current_nerds.select { |nerd| nerd["hire_date"].present? }
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
