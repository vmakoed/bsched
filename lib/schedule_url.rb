module ScheduleURL

  require 'open-uri'
  require 'nokogiri'

  def form_url(group_number)
    "https://www.bsuir.by/schedule/rest/schedule/#{get_group_id_by_number(group_number)}"
  end

  def get_group_id_by_number(group_number)
    groups_hash = parse_groups_xml(Nokogiri::XML(open('https://www.bsuir.by/schedule/rest/studentGroup')))
    find_group_id(groups_hash, group_number)
  end

  def parse_groups_xml(xml_groups)
    Hash.from_xml(xml_groups.to_s)['studentGroupXmlModels']['studentGroup']
  end

  def find_group_id(groups_hash, group_number)
    group_id = nil
    groups_hash.each do |group_info|
      if group_info['name'] == group_number
        group_id = group_info['id']
        break
      end
    end
    group_id
  end
end