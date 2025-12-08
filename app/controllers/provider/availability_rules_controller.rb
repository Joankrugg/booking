module Provider
  class AvailabilityRulesController < BaseController
    before_action :set_service
    before_action :set_rule, only: [:edit, :update, :destroy]

    def index
      @rules = @service.availability_rules.order(:weekday, :start_time)
    end

    def new
      @rule = @service.availability_rules.new
    end

    def create
      @rule = @service.availability_rules.new(rule_params)
      if @rule.save
        redirect_to provider_service_availability_rules_path(@service),
          notice: "Plage ajoutée."
      else
        render :new, status: :unprocessable_entity
      end
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
      params.require(:availability_rule).permit(:weekday, :start_time, :end_time)
    end
  end
end
