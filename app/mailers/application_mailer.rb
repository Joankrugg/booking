class ApplicationMailer < ActionMailer::Base
  default from: ENV.fetch("DEFAULT_FROM_EMAIL", "modernboxrecords@gmail.com")
  layout "mailer"
end
