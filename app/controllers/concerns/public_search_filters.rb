module PublicSearchFilters
  extend ActiveSupport::Concern
  private
  def prepare_filters(place_param)
    @date = parse_day(params[:date])
    @month = (parse_day(params[:month]) || @date || Date.current).beginning_of_month
    @radius = params[:radius].present? ? params[:radius].to_i.clamp(0, 200) : 20
    @place = params[place_param].to_s.strip.first(200)
    @page = [params[:page].to_i, 1].max
  end
  def parse_day(value)
    return if value.blank?
    Date.iso8601(value.to_s)
  rescue ArgumentError
    nil
  end
  def around_place(records, touring: false)
    return records if @place.blank?
    location = PlaceResolver.resolve(@place)
    unless location&.located?
      @location_error = "Lieu non reconnu ou service géographique momentanément indisponible. Essayez une ville précise, ou effacez le lieu pour voir toutes les dates."
      return records.none
    end
    GeographicSearch.filter(records, location, @radius, touring: touring)
  end
end
