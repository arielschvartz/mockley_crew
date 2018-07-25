module MockleyCrew
  class FactoryBuilder
    attr_accessor :factory, :options, :errors

    def initialize params = {}
      raise Errors::InvalidDataError unless params.is_a? Hash
      raise Errors::InvalidDataError unless params.keys.include?("factory")
      
      @factory = params["factory"]
      unless MockleyCrew.configuration.registered_factory?(@factory.to_sym)
        @factory = @factory.singularize
        unless MockleyCrew.configuration.registered_factory?(@factory.to_sym)
          raise Errors::InvalidFactoryError
        end
      end

      params["options"] ||= {}
      params["options"].reverse_merge!(
        "amount" => 1,
        "attributes" => {}
      )
      @options = params["options"]

      raise Errors::InvalidAmountError unless @options["amount"].to_i > 0

      @errors = {}
    end

    def save
      begin
        FactoryBot.create_list(@factory.to_sym, @options["amount"].to_i, @options["attributes"])
        return true
      rescue NoMethodError => e
        self.errors[:attributes] = { message: "Invalid Attributes", detailed_error: e }
      rescue ActiveRecord::RecordInvalid => e
        self.errors[:attributes] = { message: "Model Validation Error", detailed_error: e }
      end
      return false
    end
  end
end