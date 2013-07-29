class Response < ActiveRecord::Base
  attr_accessible :est_time, :job_id, :on_it_at, :job_id
  belongs_to :job
  belongs_to :runner

  before_create :stamp_on_it, if: proc {self.est_time == 0}
  after_create :increment_and_call_evaluate

  validates :est_time, :numericality => { :greater_than_or_equal_to => 0}, :presence => true

  private

  def stamp_on_it
		self.on_it_at = Time.now
  end

  def increment_and_call_evaluate
  	job = self.job
    job.response_count += 1
    job.save
    # maybe doesn't need to be a class method
    Job.evaluate_response_count(job)
  end

  def valid_est_time
    if !self.est_time.is_a? Integer || self.est_time >= 0
      self.errors.add("Invalid Response Estimated Time.")
    end 
  end

end