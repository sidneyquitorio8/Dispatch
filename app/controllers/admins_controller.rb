class AdminsController < ApplicationController

  before_filter :bounce_anons, :bounce_non_admin

  def index
  	@start_date = Job.first.created_at.strftime('%m/%d/%Y')
  	@response_time = mean_response_time
    @est_time = mean_est_response_time
    @completed_time = mean_completed_time
    @jobs_per_day = jobs_per_day
    @speed = time_survey
    @quality = quality_survey
    @category = category
  end

  private

  def mean_response_time
  	start_date = Job.first.created_at
  	responses = Response.all
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

  def mean_est_response_time
    start_date = Job.first.created_at
    responses = Response.all
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

  def mean_completed_time
    start_date = Job.first.created_at
    jobs = Job.all
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

  def jobs_per_day
    start_date = Job.first.created_at
    jobs = Job.all
    h = Hash.new(0)
    greatestday = 0
    jobs.each do |j|
      day = ((j.created_at - start_date)/1.day).round(0)
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

  def time_survey
    h = Hash.new(0)
    h["Fantastic"] = Survey.where(speed: "Fantastic").count
    h["Okay"] = Survey.where(speed: "Okay").count
    h["Terrible"] = Survey.where(speed: "Terrible").count
    return h
  end

  def quality_survey
    h = Hash.new(0)
    h["Fantastic"] = Survey.where(service: "Fantastic").count
    h["Okay"] = Survey.where(service: "Okay").count
    h["Terrible"] = Survey.where(service: "Terrible").count
    return h
  end

  def category
    h = Hash.new(0)
    h["Bistro Card"] = Job.where(category: "Bistro Card").count
    h["Return"] = Job.where(category: "Return").count
    h["Supplies"] = Job.where(category: "Supplies").count
    h["Catering"] = Job.where(category: "Catering").count
    h["Print"] = Job.where(category: "Print").count
    h["Research"] = Job.where(category: "Research").count
    h["Room Booking"] = Job.where(category: "Room Booking").count
    h["Other"] = Job.where(category: "Other").count
    return h
  end

end