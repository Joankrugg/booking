class WebhooksController < ApplicationController
  skip_before_action :verify_authenticity_token

  def stripe
    payload = request.body.read
    sig     = request.env['HTTP_STRIPE_SIGNATURE']

    event = Stripe::Webhook.construct_event(
	  payload,
	  sig,
	  ENV["STRIPE_WEBHOOK_SECRET"]
	)

    case event["type"]
    when "checkout.session.completed"
      session = event["data"]["object"]
      booking = Booking.find_by(checkout_session_id: session.id)

      booking.update!(
        status: "paid",
        payment_intent_id: session.payment_intent
      )
    end

    head :ok
  end
end
