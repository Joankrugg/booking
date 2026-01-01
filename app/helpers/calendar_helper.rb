module CalendarHelper
  def calendar_url(overrides = {})
    calendar_path(
      {
        date: @date,
        categories: params[:categories],
        location: params[:location]
      }.merge(overrides).compact
    )
  end
end