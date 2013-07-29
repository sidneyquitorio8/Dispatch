class ResponsesController < ApplicationController

  def create
    @response = current_runner.responses.new(params[:response])

    if @response.save
      redirect_to jobs_path, notice: 'your response has been sent!'
    else
      redirect_to jobs_path
    end
  end

  def update
  	response = Response.find(params[:id])
    response.on_it_at = Time.now
    job = response.job
    Job.delay.send_onit_email(job.id)
    Job.delay.send_onit_text(job.id)
    Job.send_onit_push(job.id)

  	response.save

    redirect_to jobs_path
  end

end