module ApplicationHelper
  def weekdays
    ["Понедельник", "Вторник", "Среда", "Четверг", "Пятница", "Суббота"]
  end

  def lesson_time_boundaries
    ["08:00-09:35", "09:45-11:20", "11:40-13:15", "13:25-15:00", "15:20-16:55", "17:05-18:40", "18:45-20:20"]
  end

  def week_numbers
    ["1", "2", "3", "4"]
  end

  def lesson_container(lesson_type)
    "lesson-container lesson-container-#{classes_by_lesson_types[lesson_type]}"
  end

  def classes_by_lesson_types
    {
      "ЛК" => "lecture",
      "ПЗ" => "seminar",
      "ЛР" => "lab"
    }
  end
end
