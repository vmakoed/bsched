class ScheduleController < ApplicationController
  def index
  end

  def generate_schedule
    redirect_to :action => "show", :group_number => params[:group_number]
  end

  def show
    @group_number = params[:group_number]
  end
end
