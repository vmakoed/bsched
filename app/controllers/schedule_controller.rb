class ScheduleController < ApplicationController
  include ApplicationHelper
  include ScheduleHelper
  include Cookies
  include ScheduleURL

  rescue_from OpenURI::HTTPError, with: :invalid_group_number

  def index
    @group_number = load_cookies[:group_number]
    @subgroup_number = load_cookies[:subgroup_number]
  end

  def get_group
    save_cookies(params)
    redirect_to action: 'show',
                group_number: params[:group_number],
                subgroup_number: params[:subgroup_number]
  end

  def show
    schedule_parser_service = ScheduleParserService.new(params, form_url(params[:group_number]))
    @schedule_info = schedule_parser_service.schedule_info
    @current_info = get_current_info
    respond_to do |format|
      format.html
      format.pdf do
        render pdf: "schedule_#{params[:group_number]}_#{params[:subgroup_number]}",
               template: 'schedule/pdf/_schedule_table.pdf.erb',
               layout: 'pdf.html.erb',
               orientation: 'landscape'
      end
    end
  end

  def invalid_group_number
    reset_cookies
    logger.error "Attempt to access invalid group_name #{params[:group_number]}"
    flash[:danger] = 'Неправильный номер группы.'
    redirect_to root_path
  end
end