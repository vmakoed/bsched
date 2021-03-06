class ScheduleParserService
  include ApplicationHelper

  require 'nokogiri'

  attr_accessor :schedule_hash, :subjects_list, :employees_list, :auditories_list

  def initialize(params, xml_with_schedule)
    @schedule_hash = Hash.new
    @subjects_list = Set.new
    @employees_list = Set.new
    @auditories_list = Set.new
    parse_schedule_xml(Nokogiri::XML(open(xml_with_schedule)), params[:subgroup_number])
  end

  def schedule_info
    {
      schedule: @schedule_hash,
      subjects: @subjects_list,
      employees: @employees_list,
      auditories: @auditories_list
    }
  end

  private

    def parse_schedule_xml(xml_schedule, subgroup_number)
      raw_hash = Hash.from_xml(xml_schedule.to_s)['scheduleXmlModels']['scheduleModel']
      form_hash(raw_hash, subgroup_number)
    end

    def form_hash(raw_hash, subgroup_number)
      week_numbers.each do |week_number|
        @schedule_hash[week_number] = form_week_hash(raw_hash, week_number, subgroup_number)
      end
    end

    def form_week_hash(raw_hash, week_number, subgroup_number)
      week_hash = Hash.new
      raw_hash.each_with_index do |(weekday_hash), index|
        week_hash[weekdays[index]] = form_weekday_hash(weekday_hash['schedule'], week_number, subgroup_number)
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
      if lesson_hash['numSubgroup'] == subgroup_number || lesson_hash['numSubgroup'] == '0'
        weekday_hash["#{lesson_hash['lessonTime']}"] ||= {}
        if lesson_time_boundaries.include? "#{lesson_hash['lessonTime']}"
          if form_lesson_hash(lesson_hash, week_number)
            weekday_hash["#{lesson_hash['lessonTime']}"] = form_lesson_hash(lesson_hash, week_number)
          end
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
      if raw_lesson_hash['weekNumber'].include? week_number
        @subjects_list << raw_lesson_hash['subject']
        if raw_lesson_hash['lessonType'] != 'Экзамен' && raw_lesson_hash['lessonType'] != 'Консультация'
          {
            'subject' => "#{raw_lesson_hash['subject']}",
            'lessonType' => "#{raw_lesson_hash['lessonType']}",
            'auditory' => extract_auditory(raw_lesson_hash['auditory']),
            'employee' => extract_employee(raw_lesson_hash['employee'])
          }
        end
      else
        nil
      end
    end

    def extract_auditory(raw_auditory)
      if raw_auditory.kind_of?(Array)
        auditory = []
        raw_auditory.each do |auditory_option|
          auditory << "#{auditory_option}"
        end
        auditory = auditory.join(', ')
      else
        auditory = raw_auditory
      end
      @auditories_list << auditory unless auditory.blank?
      auditory
    end

    def extract_employee(raw_employee)
      employee = ''
      if raw_employee
        if raw_employee.kind_of?(Array)
          employee = []
          raw_employee.each do |employee_hash|
            employee << "#{initials_from_hash(employee_hash)}"
          end
          employee = employee.join(', ')
        else
          employee = "#{initials_from_hash(raw_employee)}"
        end
      end
      @employees_list << employee unless employee.blank?
      employee
    end

    def initials_from_hash(hash)
      "#{initials(hash['lastName'], hash['firstName'], hash['middleName'])}"
    end

    def initials(first_name, last_name, middle_name)
      "#{first_name} #{last_name[0,1]}. #{middle_name[0,1]}."
    end

    def split_long_lesson(weekday_hash, long_lesson, week_number)
      start_time = long_lesson['lessonTime'][0, 5]
      finish_time = long_lesson['lessonTime'][-5, 5]
      lesson_times = lesson_time_boundaries.select {|time_boundary| time_boundary[0, 5] >= start_time && time_boundary[-5, 5] <= finish_time}
      lesson_times.each do |lesson_time|
        weekday_hash["#{lesson_time}"] = form_lesson_hash(long_lesson, week_number) if form_lesson_hash(long_lesson, week_number)
      end
      weekday_hash
    end
end