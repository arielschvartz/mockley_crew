module MockleyCrew::MockleyCrewHandled
  extend ActiveSupport::Concern

  included do
    prepend_before_action :activate_database, if: :mockley_crew_header_present?
    prepend_before_action :set_database, if: :mockley_crew_header_present?
    append_after_action :restore_database, if: :mockley_crew_header_present?
    append_after_action :set_response_header, if: :mockley_crew_header_present?

    rescue_from MockleyCrew::Errors::DatabaseNotFoundError, with: :invalid_badge
  end

  private

    def mockley_crew_header_present?
      request.headers[MockleyCrew.configuration.crew_header].present?
    end

    def activate_database
      @database.on
    end

    def restore_database
      @database.off
    end

    def set_database
      @database_name = request.headers[MockleyCrew.configuration.crew_header]
      @database = MockleyCrew::Database.find_by_name(@database_name)
    end

    def set_response_header
      return unless @database
      response.set_header(MockleyCrew.configuration.crew_header, @database.filename)
    end

    def invalid_badge
      render json: { success: false, error: "Invalid badge" }, status: 403 
    end
end