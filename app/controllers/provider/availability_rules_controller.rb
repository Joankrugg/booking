class Provider::AvailabilityRulesController < Provider::BaseController
  before_action :set_service
  before_action :set_rule, only: [:edit, :update, :destroy]

  def index
    @rules = @service.availability_rules.order(:weekday, :start_time)
  end

  def new
    @rule = @service.availability_rules.new
  end

  def create
  weekdays = rule_params.delete(:weekdays)

  if weekdays.blank?
    @rule = @service.availability_rules.new(rule_params)
    @rule.errors.add(:weekday, "doit être sélectionné")
    return render :new, status: :unprocessable_entity
  end

  AvailabilityRule.transaction do
    weekdays.each do |day|
      @service.availability_rules.create!(
        weekday: day,
        start_time: rule_params[:start_time],
        end_time: rule_params[:end_time]
      )
    end
  end

  redirect_to provider_service_availability_rules_path(@service),
    notice: "Plages ajoutées."

  rescue ActiveRecord::RecordInvalid
    @rule = @service.availability_rules.new(rule_params)
    render :new, status: :unprocessable_entity
  end


  def edit; end

  def update
    if @rule.update(rule_params)
      redirect_to provider_service_availability_rules_path(@service),
        notice: "Plage mise à jour."
    else
      render :edit, status: :unprocessable_entity
    end
  end

  def destroy
    @rule.destroy
    redirect_to provider_service_availability_rules_path(@service),
      notice: "Plage supprimée."
  end

  private

  def set_service
    @service = current_user.services.find(params[:service_id])
  end

  def set_rule
    @rule = @service.availability_rules.find(params[:id])
  end

  def rule_params
    params.require(:availability_rule).permit(:start_time, :end_time, weekdays: [])
  end

end

