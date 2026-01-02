class SubscriptionsController < ApplicationController
  before_action :authenticate_user!

  def new
    session = Stripe::Checkout::Session.create(
      mode: "subscription",
      customer_email: current_user.email,
      line_items: [{
        price: ENV["STRIPE_SUBSCRIPTION_PRICE_ID"],
        quantity: 1
      }],
      success_url: subscription_success_url,
      cancel_url: subscription_cancel_url
    )

    redirect_to session.url, allow_other_host: true
  end

  def success
  end
end
