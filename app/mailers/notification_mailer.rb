class NotificationMailer < ActionMailer::Base

  def user_assignment(job) #check
    @user = job.user.login
    @job_name = job.category
    assigned = Response.where(job_id: job.id).where("responses.assigned_at IS NOT NULL").last
    @est_completed_at = job.assigned_at + assigned.est_time.minutes
    @est = @est_completed_at.strftime('%l:%M %p')

    mail to: job.user.email, subject: "'#{@job_name}' assigned"
  end

  def runner_assignment(job) #check
    @runner = job.runner.login
    @job_name = job.category

    mail to: job.runner.email, subject: "You were assigned '#{@job_name}'"
  end

  def runner_reassignment(job, runner) #check
    @runner = runner.login
    @job_name = job.category

    mail to: runner.email, subject: "'#{@job_name}' reassigned"
  end

  def user_reassignment(job) #check
    @user = job.user.login
    @job_name = job.category

    mail to: job.user.email, subject: "'#{@job_name}' reassigned"
  end

  def user_completed(job) #check
    @user = job.user.login
    @job_name = job.category
    @job = job

    mail to: job.user.email, subject: "'#{@job_name}' completed"
  end

  def user_onit(job) #check
    @user = job.user.login
    @job_name = job.category

    mail to: job.user.email, subject: "'#{@job_name}' in process"
  end

  def job_creation(job)  #check
    @user = job.user.login
    @job_name = job.category

    mail to: job.user.email, subject: "New job '#{@job_name}' created"
  end

  def job_cancelation(job) #check
    @user = job.user.login
    @job_name = job.category

    mail to: job.user.email, subject: "'#{@job_name}' cancelled"
  end

  def runner_creation_notify(job, runner) #check
    @runner = runner.login
    @job_name = job.category

    mail to: runner.email, subject: "New Job"
  end

end
