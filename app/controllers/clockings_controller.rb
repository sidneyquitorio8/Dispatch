class ClockingsController < ApplicationController

	def create
		@clocking = current_runner.clockings.new(params[:clocking])
		@clocking.save
		redirect_to jobs_path
	end

end