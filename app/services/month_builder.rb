class MonthBuilder
  def initialize(date)
    @month = date.beginning_of_month
  end

  def build
    (@month..@month.end_of_month).map do |date|
      slots = DayAvailability.new(date).build
      {
        date: date,
        available: slots.any?,
        count: slots.count
      }
    end
  end
end
