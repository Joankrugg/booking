class ConcertsController < ApplicationController
  include PublicSearchFilters
  def index
    prepare_filters(:place)
    records = around_place(Concert.publicly_visible.where("starts_at >= ?", (@date ? @date.beginning_of_day : Time.current)))
    @concert_days = records.where(starts_at: @month.beginning_of_day..@month.end_of_month.end_of_day).where(cancelled: false).pluck(:starts_at).map(&:to_date).uniq
    records = records.where(starts_at: @date.beginning_of_day..@date.end_of_day) if @date
    @concerts = records.includes(:group).order(:starts_at).offset((@page - 1) * 50).limit(51).to_a
    @has_more = @concerts.length > 50
    @concerts = @concerts.first(50)
  end
end
