class JobsController < ApplicationController

  before_filter :bounce_anons

  def index
    @job = Job.first
    @user = current_login
    @jobs = Job.order("created_at DESC")
    @unassigned = Job.where(status: :unassigned)
    @assigned = Job.where(status: :assigned).where("runner_id != ?", @user.id)
    @active = @user.jobs.where("status = ? or status = ?", "assigned", "unassigned").order("created_at DESC")
    @history = @user.jobs.where("status = ? or status = ?", "completed", "cancelled").order("created_at DESC")
    @message = Message.new

    if is_runner?(@user)
      @last_clocking = @user.clockings.last
      @clocking = Clocking.new 
      @response = Response.new
    end
  end

  def new
    @job = Job.new
    unless !is_runner?(current_login)
      redirect_to jobs_path
    end
  end

  def show
    @job = Job.find(params[:id])
    @user = current_login

    unless (is_runner?(@user) && @job.cancelled_at.nil?) || @user.id == @job.user.id || @user.admin?
      redirect_to jobs_path
    end


    @message = Message.new
    if is_runner?(@user)
      @last_clocking = @user.clockings.last
      @clocking = Clocking.new 
      @response = Response.new
    end
  end

  def edit
    @job = Job.find(params[:id])
  end

  def create
    @job = Job.new(params[:job])
    @job.user_id = current_user.id

    if @job.save
      Job.delay(run_at: 1.minutes.from_now).buffered_assign(@job.id)

      clocked_in_runners = Runner.where(available: true)
      clocked_in_runners.each do |runner|
        Rails.cache.write(runner.login, "NEW JOB ALERT @ #{Time.now.strftime('%l:%M %p')}", expires_in: 15.minutes)
      end
      
      @job["formatted_timestamp"] = Time.now.strftime('%l:%M %p')
      Pusher['alert_channel'].trigger('new_job', @job.to_json);
      redirect_to jobs_path, notice: 'Nerdsistants have been alerted!'
    else
      render action: "new"
    end
  end

  def update
    @job = Job.find(params[:id])

    unless !is_runner?(current_login) && current_login.id == @job.user.id
      redirect_to jobs_path
    end

    @job.update_attributes(params[:job])
    redirect_to jobs_path
  end

  def destroy
    @job = Job.find(params[:id])
    @job.destroy
  end

  def runner_job
    unless is_runner?(current_login)
      redirect_to jobs_path
    end

    @job = Job.new
  end

  def runner_job_create
    category = params[:category]
    user_login = params[:user_login]
    location = params[:location]
    description = params[:description]
    user = User.where("login = ?", user_login).first

    if user.present?
      @job = Job.new(user_id: user.id, category: category, location: location, description: description)
      if @job.save
        Job.delay(run_at: 1.minutes.from_now).buffered_assign(@job.id)

        clocked_in_runners = Runner.where(available: true)
        clocked_in_runners.each do |runner|
          Rails.cache.write(runner.login, "NEW JOB ALERT @ #{Time.now.strftime('%l:%M %p')}", expires_in: 15.minutes)
        end
        
        @job["formatted_timestamp"] = Time.now.strftime('%l:%M %p')
        Pusher['alert_channel'].trigger('new_job', @job.to_json);
        redirect_to jobs_path, notice: "You sucessfully created a job for a user"
      else
        render action: "runner_job"
      end
    else
      render action: "runner_job"
    end
  end

  def user_exists?
    user_login = params[:user_login]
    user = User.where("login = ?", user_login).first
    user_exists = user.present?
    respond_to do |format|
      format.js  { render :json => user_exists.to_json}
      format.html { redirect_to jobs_path }
    end
  end

end