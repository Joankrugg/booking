class Member::AvailabilityCalendarsController < Member::BaseController
  before_action :set_group
  def show
    prepare_calendar
  end
  def update
    prepare_calendar
    return undo_change if params[:undo_token].present?
    dates = if params[:single_date].present?
      [ Date.iso8601(params[:single_date]) ]
    elsif params[:mode] == "period"
      first = Date.iso8601(params[:from].to_s)
      last = Date.iso8601(params[:to].to_s)
      raise AvailabilityBatch::Invalid, "La période doit durer entre 1 et 366 jours." unless (last - first).between?(0, 365)
      weekdays = Array(params[:weekdays]).select { |value| value.match?(/\A[0-6]\z/) }.map(&:to_i)
      (first..last).select { |day| weekdays.include?(day.wday) }
    else
      Array(params[:dates]).map { |day| Date.iso8601(day) }
    end
    attributes = params.permit(:area_name, :travel_radius_km, :starts_at_time, :ends_at_time, :public_note).to_h
    attributes.except!("starts_at_time", "ends_at_time", "public_note") unless params[:replace_details] == "1"
    action = params[:paint].to_s
    raise AvailabilityBatch::Invalid, "Choisissez un état." unless (ConcertAvailability::STATUSES.values + [ "clear" ]).include?(action)
    attributes[:status] = action unless action == "clear"
    previous = current = nil
    @group.with_lock do
      previous = @group.concert_availabilities.find_by(date: dates.first, area_key: @area_name.parameterize)&.attributes if dates.size == 1
      AvailabilityBatch.apply(group: @group, user: current_user, dates: dates, attributes: attributes, clear: action == "clear")
      current = @group.concert_availabilities.find_by(date: dates.first, area_key: @area_name.parameterize) if dates.size == 1
    end
    if request.format.json?
      token = nil
      if dates.size == 1
        token = Rails.application.message_verifier(:calendar_undo).generate(
          { user_id: current_user.id, group_id: @group.id, date: dates.first.iso8601,
            area_key: @area_name.parameterize, previous: previous, current: current&.attributes }, expires_in: 15.minutes)
      end
      return render json: { ok: true, undo_token: token }
    end
    redirect_to member_group_availability_calendar_path(@group, month: @month, area_name: @area_name, travel_radius_km: @radius), notice: "Calendrier mis à jour. Dates reconfirmées."
  rescue ArgumentError, AvailabilityBatch::Invalid => error
    @calendar_error = error.is_a?(ArgumentError) ? "Vérifiez les dates." : error.message
    if request.format.json?
      render json: { error: @calendar_error }, status: :unprocessable_entity
    else
      render :show, status: :unprocessable_entity
    end
  end
  private
  def undo_change
    data = Rails.application.message_verifier(:calendar_undo).verified(params[:undo_token])&.with_indifferent_access
    raise AvailabilityBatch::Invalid, "L’annulation a expiré." unless data && data[:user_id] == current_user.id && data[:group_id] == @group.id
    raise AvailabilityBatch::Invalid, "Une date passée ne peut pas être modifiée." if Date.iso8601(data[:date]) < Date.current
    @group.with_lock do
      current = @group.concert_availabilities.find_by(date: data[:date], area_key: data[:area_key])
      # Compare serialized snapshots to avoid differences in Ruby date/time types.
      raise AvailabilityBatch::Invalid, "Cette date a changé depuis. Rechargez le calendrier." unless current&.attributes.to_json == data[:current].to_json
      if data[:previous]
        previous = data[:previous].except("id", "created_at", "updated_at")
        record = current || @group.concert_availabilities.new
        record.assign_attributes(previous)
        record.save!
      else
        current&.destroy!
      end
    end
    render json: { ok: true, state: data[:previous]&.fetch("status", nil) || "unknown" }
  end
  def set_group
    @group = current_user.accessible_groups.find(params[:group_id])
  end
  def prepare_calendar
    @month = (Date.iso8601(params[:month].to_s) rescue Date.current).beginning_of_month
    @area_name = params[:area_name].presence || @group.city.presence || ""
    @radius = params[:travel_radius_km].presence || 50
    @records = @group.concert_availabilities.where(date: @month..@month.end_of_month, area_key: @area_name.parameterize).index_by(&:date)
  end
end
