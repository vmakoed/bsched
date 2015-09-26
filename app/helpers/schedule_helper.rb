module ScheduleHelper
  def lesson_container(lesson_type)
    "lesson-container lesson-container-#{classes_by_lesson_types[lesson_type]}"
  end

  def badge_current(lesson_type)
    "badge badge-current badge-current-#{classes_by_lesson_types[lesson_type]}"
  end

  def classes_by_lesson_types
    {
      "ЛК" => "lecture",
      "ПЗ" => "seminar",
      "ЛР" => "lab"
    }
  end

  def th_class_for_time_boundary(current_time, lesson_time_boundary)
    if current_time >= lesson_time_boundary[0, 5] && current_time <= lesson_time_boundary[-5, 5]
      "class = th-current-lesson"
    else
      nil
    end
  end

  def tr_class_for_week(week_number, current_week)
    if week_number == current_week
      "tr-current-week tr-current-week-header"
    else
      "weekday-tr"
    end
  end

  def tr_class_for_day(week_number, current_week, weekday, current_day)
    weekdays = get_weekdays
    if week_number == current_week
      if weekday == weekdays[current_day - 1]
        "class = tr-current-day"
      else
        "class = tr-current-week"
      end
    else
      nil
    end
  end

  def does_lesson_exist?(schedule_hash, week_number, weekday, lesson_time_boundary)
    does_lesson_exist = false
    if schedule_hash[week_number][weekday]
      if schedule_hash[week_number][weekday][lesson_time_boundary]
        if time_has_lessons = schedule_hash[week_number][weekday][lesson_time_boundary].any?
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
    is_current_time?(current_time, lesson_time_boundary) && week_number == current_week && weekday == get_weekdays[current_day - 1]
  end
end
