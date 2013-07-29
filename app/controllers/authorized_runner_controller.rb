class AuthorizedRunnerController < ApplicationController

	before_filter :bounce_anons, :bounce_non_admin

	def new
		@authorized_runner = AuthorizedRunner.new
	end

	def create
		@authorized_runner = AuthorizedRunner.new(login: params[:login])
		if @authorized_runner.save
			redirect_to "/admin"
		else
			render action: "new"
		end
	end



end
