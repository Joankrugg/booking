class StripeConnectController < ApplicationController
  before_action :authenticate_user!

  def create
    begin
    account = Stripe::Account.create(type: "standard")
    rescue Stripe::StripeError => e
      Rails.logger.error e.message
      redirect_to provider_dashboard_path,
                  alert: "Impossible de connecter Stripe pour le moment."
      return
    end

    current_user.update!(stripe_account_id: account.id)

    link = Stripe::AccountLink.create(
      account: account.id,
      refresh_url: refresh_stripe_connect_url,
      return_url: return_stripe_connect_url,
      type: "account_onboarding"
    )

    redirect_to link.url, allow_other_host: true
  end

  def return
    account = Stripe::Account.retrieve(current_user.stripe_account_id)

    if account.charges_enabled
      current_user.update!(stripe_connected: true)
      flash[:notice] = "Paiements activés 🎉"
    else
      current_user.update!(stripe_connected: false)
      flash[:alert] = "Finalisez la configuration de votre compte Stripe"
    end

    redirect_to provider_root_path
  end

  def refresh
    redirect_to create_stripe_connect_path
  end
end
