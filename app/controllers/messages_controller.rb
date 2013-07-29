class MessagesController < ApplicationController
	include ApplicationHelper
  include ActionView::Helpers::TextHelper
  include ActionView::Helpers::TagHelper

	def create
		@message = current_login.messages.new(params[:message])

		if @message.save
			@message["formatted_created_at"] = @message.created_at.strftime('%b %d at %l:%M%p')
			@message["login"] = @message.user_id.present? ? @message.user.login : @message.runner.login
			@message["body"] = simple_format(@message.body)
			Pusher['msg_channel'].trigger('msg_added', @message.to_json)
			redirect_to "/jobs/#{@message.job_id}", notice: "your message has been sent!"
		else
			redirect_to "/jobs/#{@message.job_id}"
		end
	end

end