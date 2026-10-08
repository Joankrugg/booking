class PublicAvailabilitiesController < ApplicationController
  include PublicSearchFilters
  layout "modern_box"
  def index
    prepare_filters(:area)
    @area = @place
    records = ConcertAvailability.joins(:group).merge(Group.publicly_visible).bookable.fresh.where("date >= ?", Date.current)
    records = around_place(records, touring: true)
    @available_days = records.where(date: @month..@month.end_of_month).distinct.pluck(:date)
    records = records.where(date: @date) if @date
    @results = records.includes(:group).order(:date, "groups.name", :area_name).offset((@page - 1) * 50).limit(51).to_a
    @has_more = @results.length > 50
    @results = @results.first(50)
  end
end
