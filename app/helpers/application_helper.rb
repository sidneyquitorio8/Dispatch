module ApplicationHelper

	def current_login
		user_signed_in? ? current_user : current_runner
	end

	def is_runner?(user)
		user.class.name == 'Runner'
	end
	
end
