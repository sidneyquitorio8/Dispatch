class Text < ActiveRecord::Base

  def self.runner_creation_text(job, runner)
  	twilio = Twilio::REST::Client.new(TWILIO_CONFIG['sid'], TWILIO_CONFIG['token'])
  	text = 'Hey ' + runner.login + '. A "' + job.category + '" job was just created.'
  	twilio.account.sms.messages.create(
      from: TWILIO_CONFIG['from'],
      to: runner.cell,
      body: text
    )
  end

  def self.job_creation_text(job)
  	twilio = Twilio::REST::Client.new(TWILIO_CONFIG['sid'], TWILIO_CONFIG['token'])
  	text = 'Hey ' + job.user.login + '. You successfully created a job named "' + job.category + '".'
  	twilio.account.sms.messages.create(
      from: TWILIO_CONFIG['from'],
      to: job.user.cell,
      body: text
    )
  end

  def self.job_cancelation_text(job)
  	twilio = Twilio::REST::Client.new(TWILIO_CONFIG['sid'], TWILIO_CONFIG['token'])
  	text = 'Hey ' + job.user.login + '. You successfully cancelled a job named "' + job.category + '".'
  	twilio.account.sms.messages.create(
      from: TWILIO_CONFIG['from'],
      to: job.user.cell,
      body: text
    )
  end

  def self.user_onit_text(job)
  	twilio = Twilio::REST::Client.new(TWILIO_CONFIG['sid'], TWILIO_CONFIG['token'])
  	text = 'Hey ' + job.user.login + '. A nerdsistant is on your job "' + job.category + '".'
  	twilio.account.sms.messages.create(
      from: TWILIO_CONFIG['from'],
      to: job.user.cell,
      body: text
    )
  end

  def self.user_completed_text(job)
  	twilio = Twilio::REST::Client.new(TWILIO_CONFIG['sid'], TWILIO_CONFIG['token'])
  	text = 'Hey ' + job.user.login + '. Your job "' + job.category + '" was completed. Help us by filling out this survey http://localhost:3000/surveys/' + job.id.to_s + "/edit"
  	twilio.account.sms.messages.create(
      from: TWILIO_CONFIG['from'],
      to: job.user.cell,
      body: text
    )
  end

  def self.user_reassignment_text(job)
  	twilio = Twilio::REST::Client.new(TWILIO_CONFIG['sid'], TWILIO_CONFIG['token'])
  	text = 'Hey ' + job.user.login + '. Your job "' + job.category + '" was reassigned to another assistant.'
  	twilio.account.sms.messages.create(
      from: TWILIO_CONFIG['from'],
      to: job.user.cell,
      body: text
    )
  end

  def self.runner_reassignment_text(job, runner)
  	twilio = Twilio::REST::Client.new(TWILIO_CONFIG['sid'], TWILIO_CONFIG['token'])
  	text = 'Hey ' + runner.login + '. The job you were assigned named "' + job.category + '" was just reassigned to another assistant.'
  	twilio.account.sms.messages.create(
      from: TWILIO_CONFIG['from'],
      to: runner.cell,
      body: text
    )
  end

  def self.runner_assignment_text(job)
  	twilio = Twilio::REST::Client.new(TWILIO_CONFIG['sid'], TWILIO_CONFIG['token'])
  	text = 'Hey ' + job.runner.login + '. Your were assigned "' + job.category + '".'
  	twilio.account.sms.messages.create(
      from: TWILIO_CONFIG['from'],
      to: job.runner.cell,
      body: text
    )
  end

    def self.user_assignment_text(job)
  	twilio = Twilio::REST::Client.new(TWILIO_CONFIG['sid'], TWILIO_CONFIG['token'])
    assigned = Response.where(job_id: job.id).where("responses.assigned_at IS NOT NULL").last
    est_completed_at = job.assigned_at + assigned.est_time.minutes
    est = est_completed_at.strftime('%l:%M %p')
  	text = 'Hey ' + job.user.login + '. Your job named "' + job.category + '" was just assigned to a assistant with estimated completed time of ' + est
  	twilio.account.sms.messages.create(
      from: TWILIO_CONFIG['from'],
      to: job.user.cell,
      body: text
    )
  end


end