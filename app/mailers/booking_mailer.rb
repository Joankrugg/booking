class BookingMailer < ApplicationMailer
  def customer_confirmation(booking)
    @booking = booking
    @service = booking.service
    @provider = @service.user

    mail(
      to: booking.customer_email,
      subject: "Réservation confirmée – #{@service.name}"
    )
  end

  def provider_notification(booking)
    @booking = booking
    @service = booking.service
    @provider = @service.user

    mail(
      to: @provider.email,
      subject: "Nouvelle réservation – #{@service.name}"
    )
  end
end
