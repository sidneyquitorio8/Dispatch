class SurveysController < ApplicationController

  before_filter :bounce_anons

  def index
    redirect_to jobs_path
  end

  def show
    @survey = Survey.find(params[:id])

    respond_to do |format|
      format.html # show.html.erb
      format.json { render json: @survey }
    end
  end

  def edit
    @survey = Survey.where(job_id: params[:id]).first
    @job = Job.find(params[:id])

    unless !is_runner?(current_login) && current_login.id == @job.user.id
      redirect_to jobs_path
    end

  end

  def update
    @survey = Survey.where(job_id: params[:id]).first
    @survey.update_attributes(params[:survey])
    redirect_to jobs_path
  end

end
