module ScheduleHelper
  def lesson_container(lesson_type)
    "lesson-container lesson-container-#{classes_by_lesson_types[lesson_type]}"
  end

  def badge_current(lesson_type)
    "badge badge-current badge-current-#{classes_by_lesson_types[lesson_type]}"
  end

  def classes_by_lesson_types
    {
      'ЛК' => 'lecture',
      'ПЗ' => 'seminar',
      'ЛР' => 'lab'
    }
  end

  def th_class_for_time_boundary(current_time, lesson_time_boundary)
    if current_time >= lesson_time_boundary[0, 5] && current_time <= lesson_time_boundary[-5, 5]
      'class = th-current-lesson'
    else
      nil
    end
  end

  def tr_class_for_week(week_number, current_week)
    if week_number == current_week
      'class = tr-current-week'
    else
      'class = weekday-tr'
    end
  end

  def tr_class_for_day(week_number, current_week, weekday, current_day)
    if week_number == current_week
      if weekday == weekdays[current_day - 1]
        'class = tr-current-day'
      else
        'class = tr-current-week'
      end
    else
      nil
    end
  end

  def does_lesson_exist?(schedule_hash, week_number, weekday, lesson_time_boundary)
    does_lesson_exist = false
    if schedule_hash[week_number][weekday]
      if schedule_hash[week_number][weekday][lesson_time_boundary]
        if schedule_hash[week_number][weekday][lesson_time_boundary].any?
          does_lesson_exist = true
        end
      end
    end
    does_lesson_exist
  end

  def is_current_time?(current_time, lesson_time_boundary)
    current_time >= lesson_time_boundary[0, 5] && current_time <= lesson_time_boundary[-5, 5]
  end

  def is_current_lesson?(current_time, lesson_time_boundary, week_number, current_week, weekday, current_day)
    is_current_time?(current_time, lesson_time_boundary) && week_number == current_week && weekday == weekdays[current_day - 1]
  end

  def get_current_info
    {
      current_week: calculate_current_week_number.to_s,
      current_day: Time.zone.now.to_date.cwday,
      current_time: get_current_time_string
    }
  end

  def calculate_current_week_number
    (((Time.zone.now.to_date.beginning_of_week - calculate_study_year_start) / 7) % 4).to_i + 1
  end

  def calculate_study_year_start
    today = Time.zone.now.to_date
    year = today.month >= 9 ? today.year : today.year - 1
    Date.new(year, 9, 1).beginning_of_week
  end

  def get_current_time_string
    hour = "#{Time.zone.now.hour}"
    min = "#{Time.zone.now.min}"
    hour.insert(0, '0') if hour.length == 1
    min.insert(0, '0') if min.length == 1
    "#{hour}:#{min}"
  end
end
