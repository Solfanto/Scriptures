class ApplicationMailer < ActionMailer::Base
  default from: email_address_with_name(Rails.configuration.x.smtp.from_address, Rails.configuration.x.smtp.from_name)
  layout "mailer"
end
