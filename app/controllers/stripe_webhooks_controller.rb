class StripeWebhooksController < ApplicationController
  skip_before_action :verify_authenticity_token

  def create
    payload = request.body.read
    sig = request.env["HTTP_STRIPE_SIGNATURE"]

    begin
      event = Stripe::Webhook.construct_event(
        payload,
        sig,
        ENV["STRIPE_WEBHOOK_SECRET"]
      )
    rescue JSON::ParserError => e
      Rails.logger.error("Stripe webhook JSON error: #{e.message}")
      return head :bad_request
    rescue Stripe::SignatureVerificationError => e
      Rails.logger.error("Stripe webhook signature error: #{e.message}")
      return head :bad_request
    end

    handle_event(event)

    head :ok
  rescue => e
    Rails.logger.error("Stripe webhook fatal error: #{e.message}")
    Rails.logger.error(e.backtrace.join("\n"))
    head :internal_server_error
  end

  private

  def handle_event(event)
    case event.type
    when "checkout.session.completed"
      handle_checkout_completed(event.data.object)
    else
      Rails.logger.info("Unhandled Stripe event: #{event.type}")
    end
  end

  def handle_checkout_completed(session)
    return unless session.mode == "subscription"
    return unless session.customer_email.present?

    user = User.find_by(email: session.customer_email)
    return unless user

    user.update!(
      stripe_customer_id: session.customer,
      subscription_status: "active"
    )
  end
end
