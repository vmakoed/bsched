module ApplicationHelper
  @@weekdays = %w(ПН ВТ СР ЧТ ПТ СБ)
  @@lesson_time_boundaries = %w(08:00-09:35 09:45-11:20 11:40-13:15 13:25-15:00 15:20-16:55 17:05-18:40 18:45-20:20)
  @@week_numbers = %w(1 2 3 4)

  def title(page_title)
    content_for(:title) { page_title }
  end

  def weekdays
    @@weekdays
  end

  def lesson_time_boundaries
    @@lesson_time_boundaries
  end

  def week_numbers
    @@week_numbers
  end
end
