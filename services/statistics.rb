class Statistics
  def monthly_array
    events = Event.confirmed.order('time ASC')
    first_time = events.first.time.beginning_of_month
    last_time = events.last.time.beginning_of_month

    last_month_index = last_time.month + (last_time.year - first_time.year)*12 - first_time.month

    array = (0..last_month_index)
    stats = [['Month', 'Events']]

    array.each do |month|
      m = month%12
      y = month/12
      this_month = first_time + month.months
      events_count = events.where(time: this_month..this_month.end_of_month).count

      stats.append([this_month.month.to_s + "/" + this_month.year.to_s, events_count])
    end
    return stats
  end

end