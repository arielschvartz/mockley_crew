module MockleyCrew
  class DatabaseController < MockleyController
    skip_before_action :activate_database
    skip_after_action :restore_database
    skip_after_action :set_response_header
    after_action :set_response_header, only: [:create]

    def create
      @database = MockleyCrew::Database.create
      render json: { success: true, database: { name: @database.filename } }, status: 201
    end

    def destroy
      if @database
        @database.destroy
        render json: { success: true }, status: 200
      else
        invalid_badge
      end
    end
  end
end
