class Survey < ActiveRecord::Base
  attr_accessible :service, :speed, :suggestion, :job_id
  belongs_to :job

  validates :speed, :presence => true
	validates :service, :presence => true

end
