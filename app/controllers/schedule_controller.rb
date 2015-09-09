class ScheduleController < ApplicationController
  include ApplicationHelper

  require 'open-uri'
  require 'nokogiri'

  def index
  end

  def get_group
    redirect_to :action => "generate", :group_number => params[:group_number], :subgroup_number => params[:subgroup_number]
  end

  def generate
    @schedule_hash = parse_schedule_xml(Nokogiri::XML(open(form_url(params[:group_number]))), params[:subgroup_number])
    @current_week = calculate_current_week_number.to_s
    @current_day = Time.zone.now.to_date.cwday
    @current_time = get_current_time_string

    respond_to do |format|
      format.html
      format.pdf do
        render pdf: "schedule_#{params[:group_number]}_#{params[:subgroup_number]}",
          template: 'schedule/pdf/generate.pdf.erb',
          layout: 'pdf.html.erb',
          page_width: '297mm',
          page_height: '875mm'
      end
    end
  end

  def form_url(group_number)
    "http://www.bsuir.by/schedule/rest/schedule/#{get_group_id_by_number(group_number)}"
  end

  def get_group_id_by_number(group_number)
    groups_hash = parse_groups_xml(Nokogiri::XML(open("http://www.bsuir.by/schedule/rest/studentGroup")))
    find_group_id(groups_hash, group_number)
  end

  def parse_groups_xml(xml_groups)
    Hash.from_xml(xml_groups.to_s)["studentGroupXmlModels"]["studentGroup"]
  end

  def find_group_id(groups_hash, group_number)
    group_id = nil
    groups_hash.each do |group_info|
      if group_info["name"] == group_number
        group_id = group_info["id"]
        break
      end
    end
    group_id
  end

  def parse_schedule_xml(xml_schedule, subgroup_number)
    raw_hash = Hash.from_xml(xml_schedule.to_s)["scheduleXmlModels"]["scheduleModel"]
    form_hash(raw_hash, subgroup_number)
  end

  def form_hash(raw_hash, subgroup_number)
    schedule_hash = Hash.new
    week_numbers.each do |week_number|
      schedule_hash[week_number] = form_week_hash(raw_hash, week_number, subgroup_number)
    end
    schedule_hash
  end

  def form_week_hash(raw_hash, week_number, subgroup_number)
    week_hash = Hash.new
    raw_hash.each_with_index do |(weekday_hash), index|
      week_hash[weekdays[index]] = form_weekday_hash(weekday_hash["schedule"], week_number, subgroup_number)
    end
    week_hash
  end

  def form_weekday_hash(raw_weekday_hash, week_number, subgroup_number)
    if does_weekday_have_multiple_lessons?(raw_weekday_hash)
      form_weekday_hash_for_multiple_lessons(raw_weekday_hash, week_number, subgroup_number)
    else
      form_weekday_hash_for_single_lesson(raw_weekday_hash, week_number, subgroup_number)
    end
  end

  def does_weekday_have_multiple_lessons?(raw_weekday_hash)
    raw_weekday_hash.kind_of?(Array)
  end

  def form_weekday_hash_for_multiple_lessons(raw_weekday_hash, week_number, subgroup_number)
    weekday_hash = {}
    raw_weekday_hash.each do |lesson_hash|
      add_lesson_to_weekday_hash(weekday_hash, lesson_hash, week_number, subgroup_number)
    end
    weekday_hash
  end

  def add_lesson_to_weekday_hash(weekday_hash, lesson_hash, week_number, subgroup_number)
    if lesson_hash["numSubgroup"] == subgroup_number || lesson_hash["numSubgroup"] == "0"
      weekday_hash["#{lesson_hash["lessonTime"]}"] ||= {}
      if lesson_time_boundaries.include? "#{lesson_hash["lessonTime"]}"
        weekday_hash["#{lesson_hash["lessonTime"]}"] = form_lesson_hash(lesson_hash, week_number) if form_lesson_hash(lesson_hash, week_number)
      else
        split_long_lesson(weekday_hash, lesson_hash, week_number)
      end
    else
      nil
    end
  end

  def form_weekday_hash_for_single_lesson(raw_weekday_hash, week_number, subgroup_number)
    weekday_hash = {}
    weekday_hash = add_lesson_to_weekday_hash(weekday_hash, raw_weekday_hash, week_number, subgroup_number)
  end

  def form_lesson_hash(raw_lesson_hash, week_number)
    if raw_lesson_hash["weekNumber"].include? week_number
      lesson_hash = Hash.new
      lesson_hash = {
        "subject" => "#{raw_lesson_hash["subject"]}",
        "lessonType" => "#{raw_lesson_hash["lessonType"]}",
        "auditory" => extract_auditory(raw_lesson_hash["auditory"]),
        "employee" => extract_employee(raw_lesson_hash["employee"])
      }
    else
      nil
    end
  end

  def extract_auditory(raw_auditory)
    auditory = ""
    if raw_auditory.kind_of?(Array)
      auditory = []
      raw_auditory.each do |auditory_option|
        auditory << "#{auditory_option}"
      end
      auditory = auditory.join(", ")
    else
      auditory = raw_auditory
    end
    auditory
  end

  def extract_employee(raw_employee)
    employee = ""
    if raw_employee
      if raw_employee.kind_of?(Array)
        employee = []
        raw_employee.each do |employee_hash|
          employee << "#{initials_from_hash(employee_hash)}"
        end
        employee = employee.join(", ")
      else
        employee = "#{initials_from_hash(raw_employee)}"
      end
    end
    employee
  end

  def initials_from_hash(hash)
    "#{initials(hash["lastName"], hash["firstName"], hash["middleName"])}"
  end

  def initials(first_name, last_name, middle_name)
    "#{first_name} #{last_name[0,1]}. #{middle_name[0,1]}."
  end

  def split_long_lesson(weekday_hash, long_lesson, week_number)
    start_time = long_lesson["lessonTime"][0, 5]
    finish_time = long_lesson["lessonTime"][-5, 5]
    lesson_times = lesson_time_boundaries.select {|time_boundary| time_boundary[0, 5] >= start_time && time_boundary[-5, 5] <= finish_time}
    lesson_times.each do |lesson_time|
      weekday_hash["#{lesson_time}"] = form_lesson_hash(long_lesson, week_number) if form_lesson_hash(long_lesson, week_number)
    end
    weekday_hash
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
    hour.insert(0, "0") if hour.length == 1
    min.insert(0, "0") if min.length == 1
    "#{hour}:{min}"
  end
end
