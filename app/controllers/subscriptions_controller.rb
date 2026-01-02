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
      cancel_url: provider_root_url
    )

    redirect_to session.url, allow_other_host: true
  end

  def success
    flash[:notice] = "Abonnement en cours d’activation…"
    redirect_to provider_root_path
  end

  def cancel
    flash[:alert] = "Abonnement annulé."
    redirect_to provider_root_path
  end
end
