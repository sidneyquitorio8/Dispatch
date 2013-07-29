class Message < ActiveRecord::Base
  attr_accessible :body, :job_id
  belongs_to :user
  belongs_to :runner
  belongs_to :job

  after_create :send_email, :send_message_pusher

  validates :body, :presence => true


  private

  def delayed_email(recipient)
    MessageMailer.app_message(self, recipient.email).deliver
  end

  def send_email
  	if  self.user_id && self.job.runner && self.job.runner.send_email == true
      delay.delayed_email(self.job.runner)
  		#MessageMailer.app_message(self, self.job.runner.email).deliver
  	elsif self.runner_id && self.job.user.send_email == true
      delay.delayed_email(self.job.user)
  		#MessageMailer.app_message(self, self.job.user.email).deliver
  	end
  end

  def send_message_pusher
    #Rails.cache.write(job.user.login, "'#{job.name}' has new message", expires_in: 15.seconds)
    Pusher['user'+self.job.user_id.to_s+'_updates'].trigger('new-notification', "'#{job.category}' has new message") if self.user.nil? || self.user != self.job.user
    Pusher['runner'+self.job.runner_id.to_s+'_updates'].trigger('new-notification', "Your job: '#{job.category}' has new message") if self.job.runner.present?
    #Pusher['user'+self.job.user_id.to_s+'_updates'].trigger('update','Job has new message')
    #pusher realtime already working, and this only provides 'real time' for the user, not other runners looking at the job
  end

end