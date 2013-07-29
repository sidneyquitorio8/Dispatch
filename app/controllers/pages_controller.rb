class PagesController < ApplicationController

  def landing
    render layout: false
  end

  def transmit
  	twilio = Twilio::REST::Client.new(TWILIO_CONFIG['sid'], TWILIO_CONFIG['token'])
  	
  	twilio.account.sms.messages.create(
      from: TWILIO_CONFIG['from'],
      to: '+19175650306',
      body: "twilio in your face"
    )

  	render text: "message on the way!"
  end

  def receive
  	twilio = Twilio::REST::Client.new(TWILIO_CONFIG['sid'], TWILIO_CONFIG['token'])
    
    twilio.account.sms.messages.create(
      from: TWILIO_CONFIG['from'],
      to: '+19175650306',
      body: params['From'].to_s + params['Body'].to_s + params['SmsSid'].to_s
    )

    render nothing: true
  end

    def self.runner_creation_text(job, runner)
    twilio = Twilio::REST::Client.new(TWILIO_CONFIG['sid'], TWILIO_CONFIG['token'])
    text = 'Hey runner.login, a job named "' + job.name + '" was just created'
    twilio.account.sms.messages.create(
      from: TWILIO_CONFIG['from'],
      to: '+19175650306',
      body: "test"
    )
    render text: "message on the way!"
  end

end