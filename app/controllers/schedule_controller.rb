class ScheduleController < ApplicationController
  require 'open-uri'
  require 'nokogiri'

  WEEKDAYS = ["Понедельник", "Вторник", "Среда", "Четверг", "Пятница", "Суббота"]

  def index
  end

  def get_group
    redirect_to :action => "generate", :group_number => params[:group_number]
  end

  def generate
    @schedule_hash = parse_xml(Nokogiri::XML(open(form_url(params[:group_number]))))
  end

  def form_url(group_number)
    "http://www.bsuir.by/schedule/rest/schedule/#{group_number}"
  end

  def parse_xml(xml_schedule)
    raw_hash = Hash.from_xml(xml_schedule.to_s)["scheduleXmlModels"]["scheduleModel"]
    schedule_hash = form_hash(raw_hash)
  end

  def form_hash(raw_hash)
    schedule_hash = Hash.new
    raw_hash.each_with_index do |(weekday_hash), index|
      schedule_hash[WEEKDAYS[index]] = form_weekday_hash(weekday_hash["schedule"])
    end
    schedule_hash
  end

  def form_weekday_hash(raw_weekday_hash)
    if does_weekday_have_multiple_lessons?(raw_weekday_hash)
      form_weekday_hash_for_multiple_lessons(raw_weekday_hash)
    else
      form_weekday_hash_for_single_lesson(raw_weekday_hash)
    end
  end

  def does_weekday_have_multiple_lessons?(raw_weekday_hash)
    raw_weekday_hash.kind_of?(Array)
  end

  def form_weekday_hash_for_multiple_lessons(raw_weekday_hash)
    weekday_hash = {}
    raw_weekday_hash.each do |lesson_hash|
      weekday_hash["#{lesson_hash["numSubgroup"]}"] ||= []
      weekday_hash["#{lesson_hash["numSubgroup"]}"] << form_weekday_hash_for_single_lesson(lesson_hash)
    end
    weekday_hash
  end

  def form_weekday_hash_for_single_lesson(raw_weekday_hash)
    weekday_hash = {}
    weekday_hash["#{raw_weekday_hash["numSubgroup"]}"] = form_lesson_hash(raw_weekday_hash)
  end

  def form_lesson_hash(raw_lesson_hash)
    lesson_hash = Hash.new
    lesson_hash["#{raw_lesson_hash["lessonTime"]}"] = {
      "subject" => "#{raw_lesson_hash["subject"]}",
      "lessonType" =>  "#{raw_lesson_hash["lessonType"]}"
    }
    lesson_hash
  end
end
