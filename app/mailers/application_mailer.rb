class ApplicationMailer < ActionMailer::Base
  default from: ENV.fetch("DEFAULT_FROM_EMAIL", "admin@slotbook.app")
  layout "mailer"
end
