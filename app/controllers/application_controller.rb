class ApplicationController < ActionController::Base

  rescue_from DeviseLdapAuthenticatable::LdapException do |exception|
    render :text => exception, :status => 500
  end

  protect_from_forgery

  private

	def bounce_anons
  	unless signed_in?
	  	redirect_to '/'
	  end
  end

  def bounce_non_admin
  	unless current_login.admin?
  		redirect_to '/'
  	end
  end

	def signed_in?
    !current_login.nil?
  end

	def current_login
		user_signed_in? ? current_user : current_runner
	end

	def is_runner?(user)
		user.class.name == 'Runner'
	end

	def after_sign_in_path_for(resource)
		jobs_path

		visitor = current_login
		visitor_login = visitor.login

		if is_runner?(visitor)
			if AuthorizedRunner.where(login: visitor_login).first.present?
				jobs_path
			else
				visitor.destroy
				root_path
			end
		# elsif authorized_runners.include? visitor
		# 	visitor.destroy
		# 	new_runner_session_path
		else
			jobs_path
		end
	end

	def after_sign_out_path_for(resource)
		if is_runner?(current_login)
			new_runner_session_path
		else
			root_path
		end
	end

	helper_method :current_login, :signed_in?, :is_runner?
end
