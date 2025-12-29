class WebhooksController < ApplicationController
  skip_before_action :verify_authenticity_token

  def stripe
    payload = request.body.read
    sig_header = request.env["HTTP_STRIPE_SIGNATURE"]

    event = Stripe::Webhook.construct_event(
      payload,
      sig_header,
      ENV["STRIPE_WEBHOOK_SECRET"]
    )

    case event.type
    when "checkout.session.completed"
      session = event.data.object
      booking_id = session.metadata.booking_id

      booking = Booking.find_by(id: booking_id)

      booking.update!(
        status: "confirmed",
        payment_intent_id: session.payment_intent
      ) if booking
    end

    render json: { ok: true }
  rescue JSON::ParserError, Stripe::SignatureVerificationError
    render json: { error: "invalid" }, status: 400
  end
  

end
