class BookingsController < ApplicationController
  layout 'calendar'
  def new
    @service = Service.find(params[:service_id])

    @booking = @service.bookings.new(
      start_time: params[:start_time],
      end_time:   params[:end_time]
    )
  end

  def create
    @service = Service.find(params[:service_id])

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

      # création du booking
      @booking = @service.bookings.new(booking_params)
      @booking.status = "pending"
      @booking.amount_cents = @service.price_euros * 100
      @booking.save!

      # 💳 Stripe Checkout
      session = Stripe::Checkout::Session.create(
        mode: "payment",
        line_items: [{
          quantity: 1,
          price_data: {
            currency: "eur",
            unit_amount: @booking.amount_cents,
            product_data: {
              name: @service.name
            }
          }
        }],
        customer_email: @booking.customer_email,
        success_url: success_service_booking_url(@service, @booking),
        cancel_url: cancel_service_booking_url(@service, @booking),
        metadata: {
          booking_id: @booking.id
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
