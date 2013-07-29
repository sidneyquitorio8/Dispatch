class RunnersController < ApplicationController

	before_filter :bounce_anons

	def index
		unless current_login.admin?
			redirect_to jobs_path
		end
		@runners = Runner.all
	end

	def edit
		@runner = Runner.find(params[:id])
		if !is_runner?(current_login) || current_login.id != @runner.id
			redirect_to @runner
		end
	end

	def update
		@runner = Runner.find(params[:id])
		if !is_runner?(current_login) || current_login.id != @runner.id
			redirect_to @runner
		end
		input_cell = params[:runner][:cell]
		if input_cell.blank?
			params[:runner][:cell] = nil
		else
			params[:runner][:cell] = "+1" + input_cell if input_cell[0..1] != "+1"
		end
		if @runner.update_attributes(params[:runner])
			redirect_to @runner, notice: "Information updated"
		else
			@runner = Runner.find(params[:id])
			render action: "edit"
		end
	end

	def show
		@runner = Runner.find(params[:id])
		@login = @runner.login
		@name = @runner.name
		@email = @runner.email
		@cell = @runner.cell
		@send_text = @runner.send_text
		@send_email = @runner.send_email
		@start_date = Job.first.created_at.strftime('%m/%d/%Y')
		@response_time = response_time(@runner)
		@est_time = est_time(@runner)
		@completed_time = completed_time(@runner)
		@jobs_per_day = jobs_per_day(@runner)
		@speed = speed(@runner)
		@quality = quality(@runner)
		unless (is_runner?(current_login) && current_login.id == @runner.id) || current_login.admin?
			redirect_to jobs_path
		end
	end

	private

	def response_time(runner)
		start_date = Job.first.created_at
  	responses = runner.responses
  	h = Hash.new(0)
  	count = Hash.new(0)
    greatestday = 0
  	responses.each do |r|
  		day = ((r.created_at - start_date)/1.day).round(0)
      if day >= greatestday
        greatestday = day
      end
  		h[day] += r.created_at - r.job.created_at
  		count[day] += 1
  	end

  	h.each_pair do |k, v|
  		h[k] = h[k]/count[k]
      h[k] = h[k]/1.minute
  	end

    for i in 0..greatestday
      if h[i] == 0
        h[i] = 0
      end
    end
    h = h.sort
  	return h
	end

	def est_time(runner)
    start_date = Job.first.created_at
    responses = runner.responses
    h = Hash.new(0)
    count = Hash.new(0)
    greatestday = 0
    responses.each do |r|
      day = ((r.created_at - start_date)/1.day).round(0)
      if day >= greatestday
        greatestday = day
      end
      h[day] += r.est_time
      count[day] += 1
    end

    h.each_pair do |k, v|
      h[k] = h[k]/count[k]
    end

    for i in 0..greatestday
      if h[i] == 0
        h[i] = 0
      end
    end
    h = h.sort
    return h
	end

	def completed_time(runner)
    start_date = Job.first.created_at
    jobs = runner.jobs
    h = Hash.new(0)
    count = Hash.new(0)
    greatestday = 0
    jobs.each do |j|
      if j.completed_at.present?

        day = ((j.completed_at - start_date)/1.day).round(0)
        if day >= greatestday
          greatestday = day
        end
      
        h[day] += j.completed_at - j.created_at
        count[day] += 1
      end
    end
    h.each_pair do |k, v|
      h[k] = h[k]/count[k]
      h[k] = h[k]/1.minute
    end
    for i in 0..greatestday
      if h[i] == 0
        h[i] = 0
      end
    end
    h = h.sort
    return h
	end

	def jobs_per_day(runner)
    start_date = Job.first.created_at
    jobs = runner.jobs
    h = Hash.new(0)
    greatestday = 0
    jobs.each do |j|
      day = ((j.assigned_at - start_date)/1.day).round(0)
      if day >= greatestday
        greatestday = day
      end
      h[day] += 1
    end

    for i in 0..greatestday
      if h[i] == 0
        h[i] = 0
      end
    end

    h = h.sort
    return h
	end

	def speed(runner)
    h = Hash.new(0)
    h["Fantastic"] = runner.surveys.where(speed: "Fantastic").count
    h["Okay"] = runner.surveys.where(speed: "Okay").count
    h["Terrible"] = runner.surveys.where(speed: "Terrible").count
    return h
	end

	def quality(runner)
		h = Hash.new(0)
    h["Fantastic"] = runner.surveys.where(service: "Fantastic").count
    h["Okay"] = runner.surveys.where(service: "Okay").count
    h["Terrible"] = runner.surveys.where(service: "Terrible").count
    return h
	end

end