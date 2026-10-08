class GroupsController < ApplicationController
  layout "modern_box"
  def index
    @groups = Group.publicly_visible.order(:name)
  end
  def show
    @group = Group.publicly_visible.find(params[:id])
    @concerts = @group.concerts.where(published: true).where("starts_at >= ?", Time.current).order(:starts_at)
    @availabilities = @group.concert_availabilities.bookable.fresh.where("date >= ?", Date.current).order(:date, :area_name).limit(60)
  end
end
