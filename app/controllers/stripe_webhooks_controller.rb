class StripeWebhooksController < ApplicationController
  skip_before_action :verify_authenticity_token

  def create
    payload = request.body.read
    sig_header = request.env["HTTP_STRIPE_SIGNATURE"]

    event = Stripe::Webhook.construct_event(
      payload,
      sig_header,
      Rails.application.credentials.stripe[:webhook_secret]
    )

    case event.type
    when "checkout.session.completed"
      handle_checkout_completed(event.data.object)
    end

    render json: { status: "ok" }
  rescue JSON::ParserError, Stripe::SignatureVerificationError => e
    render json: { error: e.message }, status: 400
  end

  private

  def handle_checkout_completed(session)
    return unless session.mode == "payment"

    booking = Booking.find_by(checkout_session_id: session.id)
    return unless booking

    booking.update!(
      status: "paid",
      payment_intent_id: session.payment_intent
    )
  end
end
