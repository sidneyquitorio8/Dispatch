class UsersController < ApplicationController

	before_filter :bounce_anons
	
	def index
		unless current_login.admin?
			redirect_to jobs_path
		end
		@users = User.all
	end

	def edit
		@user = User.find(params[:id])
		if is_runner?(current_login) || current_login.id != @user.id
			redirect_to @user
		end
	end

	def update
		@user = User.find(params[:id])
		if is_runner?(current_login) || current_login.id != @user.id
			redirect_to @user
		end
		input_cell = params[:user][:cell]
		if input_cell.blank?
			params[:user][:cell] = nil
		else
			params[:user][:cell] = "+1" + input_cell if input_cell[0..1] != "+1"
		end
		if @user.update_attributes(params[:user])
			redirect_to @user, notice: "Information updated"
		else
			@user = User.find(params[:id])
			render action: "edit"
		end
	end

	def show
		@user = User.find(params[:id])
		@login = @user.login
		@name = @user.name
		@email = @user.email
		@cell = @user.cell
		@send_text = @user.send_text
		@send_email = @user.send_email
		@start_date = Job.first.created_at.strftime('%m/%d/%Y')
		@response_time = response_time(@user)
		@est_time = est_time(@user)
		@completed_time = completed_time(@user)
		@jobs_per_day = jobs_per_day(@user)
		@speed = speed(@user)
		@quality = quality(@user)
		unless (!is_runner?(current_login) && current_login.id == @user.id) || current_login.admin?
			redirect_to jobs_path
		end
	end

	def edit_admin
		#just a normal render
	end

	def update_admin
		@user = User.where(login: params[:user_login]).first
		if @user.present? && @user.toggle!(:admin)
			redirect_to "/admin"
		else
			render action: "edit_admin"
		end
	end


	private

	def response_time(user)
		start_date = Job.first.created_at
  	responses = user.responses
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

	def est_time(user)
    start_date = Job.first.created_at
    responses = user.responses
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

	def completed_time(user)
    start_date = Job.first.created_at
    jobs = user.jobs
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

	def jobs_per_day(user)
    start_date = Job.first.created_at
    jobs = user.jobs
    h = Hash.new(0)
    greatestday = 0
    if jobs.present?
	    jobs.each do |j|
	      day = ((j.created_at - start_date)/1.day).round(0)
	      if day >= greatestday
	        greatestday = day
	      end
	      h[day] += 1
	    end
	  end
    for i in 0..greatestday
      if h[i] == 0
        h[i] = 0
      end
    end

    h = h.sort
    return h
	end

	def speed(user)
    h = Hash.new(0)
    h["Fantastic"] = user.surveys.where(speed: "Fantastic").count
    h["Okay"] = user.surveys.where(speed: "Okay").count
    h["Terrible"] = user.surveys.where(speed: "Terrible").count
    return h
	end

	def quality(user)
		h = Hash.new(0)
    h["Fantastic"] = user.surveys.where(service: "Fantastic").count
    h["Okay"] = user.surveys.where(service: "Okay").count
    h["Terrible"] = user.surveys.where(service: "Terrible").count
    return h
	end

end