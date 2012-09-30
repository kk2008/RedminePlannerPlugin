class PlanDetailsController < ApplicationController
  unloadable
  menu_item :planner

  before_filter :find_project_by_request_id, :only => [:index, :new, :create]
  before_filter :find_plan_detail, :only => [:show, :edit, :update, :destroy]
  before_filter :authorize_request, :except => [:index, :show]
  before_filter :authorize

  def index
    respond_to do |format|
      format.html { redirect_to plan_request_url(@plan_request)}
      format.json { render :json => @plan_request.details }
    end
  end


  def create
    @plan_detail = PlanDetail.new(params[:plan_detail])
    @plan_request.details << @plan_detail

    respond_to do |format|
      if @plan_detail.save
        format.html { redirect_to plan_request_url(@plan_request), :notice => l(:notice_successful_create) }
        format.json { render :json => @plan_detail, :status => :created, :location => @plan_detail }
        format.js   { render :action => "refresh" }
      else
        format.html { render :action => "new" }
        format.json { render :json => @plan_detail.errors, :status => :unprocessable_entity }
      end
    end
  end

  def update
    # FIXME
  end

  def destroy
    @plan_detail.destroy

    respond_to do |format|
      format.html { redirect_to plan_request_url(@plan_request), :notice => l(:notice_successful_delete) }
      format.json { head :no_content }
      format.js   { render :action => "refresh" }
    end
  end

private

  def find_project_by_request_id
    @plan_request = PlanRequest.find(params[:plan_request_id], :include => { :task => :project })
    return render_403 unless @plan_request.present?
    @project = @plan_request.task.project
  end

  def find_plan_detail
    @plan_detail = PlanDetail.find(params[:id], :include => [ {:request => :task} ])
    return render_403 unless @plan_detail.present?

    @plan_request = @plan_detail.request
    @project = @plan_request.task.project
  end

  def authorize_request
    render_403 unless @plan_request.can_edit?
  end
end