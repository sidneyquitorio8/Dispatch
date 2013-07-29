class Job < ActiveRecord::Base
  attr_accessible :description, :location, :status, :user_id, :runner_id, :category
  belongs_to :user
  belongs_to :runner
  has_many :messages
  has_many :responses
  has_one :survey

	before_update :stamp_cancelled_at, if: proc {self.status_changed? && self.status == 'cancelled'}
	before_update :stamp_completed_at, if: proc {self.status_changed? && self.status == 'completed'}
	after_create :send_create_email_and_text
	after_create :create_survey


	validates :description, :presence => true
	validates :location, :presence => true
	validates :user_id, :presence => true
	CATEGORIES = ["Bistro Card", "Supplies", "Return", "Catering", "Print", "Research", "Room Booking", "Other"]
	validates :category, :inclusion => {:in => CATEGORIES}


	def assign
		assigned = self.responses.min_by do |response|
		  				   response.est_time
							 end

		if assigned.present?
			self.runner_id = assigned.runner_id
			self.assigned_at = Time.now
			self.status = 'assigned'
			self.save
			assigned.assigned_at = Time.now
			assigned.save
      send_assigned_push
		end
	end

	def self.evaluate_response_count(job)
		if Runner.where(available: true).length == job.response_count && job.status == "unassigned"
			job.assign
			Job.delay.send_assigned_emails(job.id)
			Job.delay.send_assigned_texts(job.id)
		elsif job.buffer_ran == true
			Job.post_buffer_response(job)
		end
	end


	def self.buffered_assign(id)
		job = Job.find(id)
		if job.status == 'unassigned'
			job.assign
			if job.status == 'assigned'
				Job.send_assigned_emails(id)
				Job.send_assigned_texts(id)
				assigned_response = Response.where(job_id: job.id).where("responses.assigned_at IS NOT NULL").last
				if(assigned_response.est_time == 0)
					Job.send_onit_email(id)
					Job.send_onit_text(id)
					Job.send_onit_push(id)
				end
			end
		end
		job.buffer_ran = true
		job.save
	end


	def self.post_buffer_response(job)
		if job.status == "unassigned"
			job.assign
			Job.delay.send_assigned_emails(job.id)
			Job.delay.send_assigned_texts(job.id)
		else
			assigned_response = Response.where(job_id: job.id).where("responses.assigned_at IS NOT NULL").last
			est_completed_at = job.assigned_at + assigned_response.est_time.minutes
			time_left = est_completed_at - Time.now
			new_est_completed_at = Response.last.est_time.minutes
			if new_est_completed_at < time_left/2 && time_left > 1200 && assigned_response.on_it_at.nil?
				Job.delay.send_reassigned_emails(job.id, job.runner.id)
				Job.delay.send_reassigned_texts(job.id, job.runner.id)
				Job.send_reassigned_push(job, job.runner)
				job.assign
				Job.delay.send_new_runner_email(job.id)
				Job.delay.send_new_runner_text(job.id)
			end
		end
	end

	#NOTIFICATIONS
	def self.send_assigned_emails(id)
		job = Job.find(id)
		NotificationMailer.user_assignment(job).deliver if job.user.send_email == true
  	NotificationMailer.runner_assignment(job).deliver if job.runner.send_email == true
	end

	def self.send_assigned_texts(id)
		job = Job.find(id)
		Text.user_assignment_text(job) if job.user.send_text == true && job.user.cell.present?
  	Text.runner_assignment_text(job) if job.runner.send_text == true && job.runner.cell.present?
	end

	def self.send_reassigned_emails(job_id, runner_id)
		job = Job.find(job_id)
		runner = Runner.find(runner_id)
		NotificationMailer.user_reassignment(job).deliver if job.user.send_email == true
		NotificationMailer.runner_reassignment(job, runner).deliver if runner.send_email == true
	end

  def self.send_reassigned_texts(job_id, runner_id)
		job = Job.find(job_id)
		runner = Runner.find(runner_id)
		Text.user_reassignment_text(job) if job.user.send_text == true && job.user.cell.present?
		Text.runner_reassignment_text(job, runner) if runner.send_text == true && runner.cell.present?
	end

	def self.send_new_runner_email(id)
		job = Job.find(id)
		NotificationMailer.runner_assignment(job).deliver if job.runner.send_email == true
	end

	def self.send_new_runner_text(id)
		job = Job.find(id)
		Text.runner_assignment_text(job) if job.runner.send_text == true && job.runner.cell.present?
	end

	def self.send_cancelation_email(id)
		job = Job.find(id)
		NotificationMailer.job_cancelation(job).deliver if job.user.send_email == true
	end

	def self.send_cancelation_text(id)
		job = Job.find(id)
		Text.job_cancelation_text(job) if job.user.send_text == true && job.user.cell.present?
	end

	def self.send_creation_email(id)
		job = Job.find(id)
		NotificationMailer.job_creation(job).deliver if job.user.send_email == true
		clocked_in_runners = Runner.where(available: true)
		clocked_in_runners.each do |runner|
			NotificationMailer.runner_creation_notify(job, runner).deliver if runner.send_email == true
		end
	end

	def self.send_creation_text(id)
		job = Job.find(id)
		Text.job_creation_text(job) if job.user.send_text == true && job.user.cell.present?
		clocked_in_runners = Runner.where(available: true)
		clocked_in_runners.each do |runner|
			Text.runner_creation_text(job, runner) if runner.send_text == true && runner.cell.present?
		end
	end

	def self.send_completed_email(id)
		job = Job.find(id)
		NotificationMailer.user_completed(job).deliver if job.user.send_email == true
	end

	def self.send_completed_text(id)
		job = Job.find(id)
		Text.user_completed_text(job) if job.user.send_text == true && job.user.cell.present?
	end

	def self.send_onit_email(id)
		job = Job.find(id)
		NotificationMailer.user_onit(job).deliver if job.user.send_email == true
	end

	def self.send_onit_text(id)
		job = Job.find(id)
		Text.user_onit_text(job) if job.user.send_text == true && job.user.cell.present?
	end

	def self.send_onit_push(id)
		job = Job.find(id)
  	Pusher['user'+job.user_id.to_s+'_updates'].trigger('new-notification',"A assistant is processing your job: '#{job.category}'")
  end

  def self.send_reassigned_push(job, runner)
  	Rails.cache.write(runner.login, "'#{job.category}' was reassigned to another assistant", expires_in: 15.seconds)
  	Pusher['runner'+runner.id.to_s+'_updates'].trigger('reassigned', job.to_json)
  end


	private

	def stamp_cancelled_at
		job = Job.find(id)
		if job.status == "assigned"
			self.status = "assigned"
		else
			self.cancelled_at = Time.now
			Job.delay.send_cancelation_text(self.id)
			Job.delay.send_cancelation_email(self.id)
			send_cancelled_push
		end
	end

	def stamp_completed_at
		self.completed_at = Time.now
		Job.delay.send_completed_email(self.id)
		Job.delay.send_completed_text(self.id)
    send_completed_push
	end

	def send_create_email_and_text
		Job.delay.send_creation_text(self.id)
		Job.delay.send_creation_email(self.id)
  end

  def create_survey
  	survey = Survey.new(job_id: self.id)
  	survey.save(validate: false)
  end

  def send_cancelled_push
  	clocked_in_runners = Runner.where(available: true)
    clocked_in_runners.each do |runner|
      Rails.cache.write(runner.login, "'#{self.category}' was cancelled", expires_in: 15.seconds)
    end
    Pusher['alert_channel'].trigger('cancelled_job', self.to_json);
  end

  def send_assigned_push
    assigned = Response.where(job_id: self.id).where("responses.assigned_at IS NOT NULL").last
		est_completed_at = self.assigned_at + assigned.est_time.minutes
		self["formatted_est_completed_at"] = est_completed_at.strftime('%l:%M %p %b %d')
    self["formatted_timestamp"] = Time.now.strftime('%l:%M %p')
    self["user_login"] = self.user.login
    self["runner_login"] = self.runner.login
    self["runner_gravatar"] = gravataruser(self.runner)
    Pusher['user'+self.user_id.to_s+'_updates'].trigger('assigned', self.to_json)

    #realtime through refresh, change this later
    Rails.cache.write(runner.login, "You were just assigned the job '#{self.category}'", expires_in: 15.seconds)
    Pusher['runner'+self.runner_id.to_s+'_updates'].trigger('assigned', self.to_json)
  end

  def send_completed_push
    self["formatted_timestamp"] = Time.now.strftime('%l:%M %p')
    self["formatted_completed_at"] = self.completed_at.strftime('%l:%M %p %b %d')
    Pusher['user'+self.user_id.to_s+'_updates'].trigger('completed', self.to_json)
    Pusher['runner'+self.runner_id.to_s+'_updates'].trigger('completed', self.to_json)
  end




end