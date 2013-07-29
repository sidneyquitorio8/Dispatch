class MessageMailer < ActionMailer::Base

  def app_message(message, email)
    @body = message.body
    @from = if message.user_id
    					message.user.login
    				elsif message.runner_id
    					message.runner.login
    				end

    mail to: email, subject: "New message for your job #{message.job.category}"
  end

end