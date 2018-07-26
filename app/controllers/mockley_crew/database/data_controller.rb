module MockleyCrew
  class Database::DataController < MockleyController
    rescue_from MockleyCrew::Errors::InvalidDataError do |exception|
      render json: { success: false, message: "Invalid body structure" }, status: 400
    end

    rescue_from MockleyCrew::Errors::InvalidFactoryError do |exception|
      render json: { success: false, message: "Invalid Factory", detailed_error: exception }, status: 400
    end

    def create
      data = MockleyCrew::Data.new(data_params.to_h["_json"])
      if data.save
        render json: { success: true }, status: 201
      else
        render json: { success: false, request: data.as_json }, status: 422
      end
    end

    private

      def data_params
        params.permit!
      end
  end
end