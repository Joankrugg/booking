class MonthBuilder
  def initialize(date)
    @date = date
  end

  def build
    range = @date.beginning_of_month..@date.end_of_month

    range.map do |day|
      {
        date: day,
        available: available_on?(day)
      }
    end
  end

  private

  def available_on?(day)
    DayAvailability.new(day).build.any?
  end
end