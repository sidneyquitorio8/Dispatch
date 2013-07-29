class Clocking < ActiveRecord::Base
 	attr_accessible :direction
  belongs_to :runner

  after_create :toggle_runner

  private

  def toggle_runner
  	runner = Runner.find(self.runner_id)

  	if self.direction == 'in'
  		runner.available = true
  	else
  		runner.available = false
  	end
  	runner.save
  end

end