class BookingsController < ApplicationController
  layout 'booking'
  def new
    @service = Service.find(params[:service_id])

    @booking = @service.bookings.new(
      start_time: params[:start_time],
      end_time:   params[:end_time]
    )
  end

  def create

    @service = Service.find(params[:service_id])
    provider = @service.user

    unless provider.stripe_connected? && provider.subscription_status == "active"
      redirect_to calendar_path,
                  alert: "Cette activité sera bientôt réservable."
      return
    end
    unless @service.reservable_on?(booking_params[:start_time].to_date)
      @booking = @service.bookings.new(booking_params)
      @booking.errors.add(
        :base,
        "Ce service doit être réservé au minimum #{@service.min_notice_days} jour(s) à l’avance."
      )
      return render :new, status: :unprocessable_entity
    end
    Booking.transaction do
      # 🔒 verrou pessimiste sur les bookings du service
      Booking.where(service_id: @service.id).lock(true)

      # ⛔️ vérification métier
      if Booking.overlapping?(
        @service.id,
        booking_params[:start_time],
        booking_params[:end_time]
      )
        @booking = @service.bookings.new(booking_params)
        @booking.errors.add(
          :base,
          "Ce créneau vient d’être réservé par quelqu’un d’autre."
        )
        return render :new, status: :conflict
      end

      @booking = @service.bookings.new(booking_params)
      @booking.status = "pending"
      @booking.amount_cents = @service.price_euros * 100
      @booking.save!

      # 🧠 garde-fous produit (ÉTAPE 8)
      provider = @service.user

      unless provider.stripe_connected?
        raise ActiveRecord::Rollback, "Prestataire non connecté à Stripe"
      end

      unless provider.subscription_status == "active"
        raise ActiveRecord::Rollback, "Abonnement inactif"
      end

      # 💳 Stripe Checkout
      session = Stripe::Checkout::Session.create(
        {
          mode: "payment",
          line_items: [{
            price_data: {
              currency: "eur",
              product_data: { name: @service.name },
              unit_amount: @booking.amount_cents
            },
            quantity: 1
          }],
          payment_intent_data: {
            application_fee_amount: (@booking.amount_cents * 0.05).to_i
          },
          success_url: success_service_booking_url(@service, @booking),
          cancel_url: cancel_service_booking_url(@service, @booking)
        },
        {
          stripe_account: @service.user.stripe_account_id
        }
      )

      @booking.update!(checkout_session_id: session.id)
      redirect_to session.url, allow_other_host: true

    end
  end

  def success
    @booking = Booking.find(params[:id])
  end

  def cancel
    @booking = Booking.find(params[:id])
    @booking.update(status: "cancelled")
    redirect_to root_path
  end


  def show
    @booking = Booking.find(params[:id])
  end

  private

  def booking_params
    params.require(:booking).permit(
      :service_id,
      :start_time,
      :end_time,
      :customer_name,
      :customer_email
    )
  end
end
