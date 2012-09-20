module DashboardHelper

  def pretty_time(time)
    offset = Time.now - time

    if offset < 1.hour
      t('time.ago.minutes', :count => (offset.to_i / 60))
    elsif offset < 12.hours
      t('time.ago.hours', :count => (offset.to_i) / 60 / 60)
    elsif offset < 1.week
      time.strftime('%A, %H:%M:%S')
    end
  end

end
