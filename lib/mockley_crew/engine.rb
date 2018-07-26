module MockleyCrew
  class Engine < ::Rails::Engine
    isolate_namespace MockleyCrew
    # config.generators.api_only = true

    config.generators do |g|
      g.test_framework :rspec
      # g.fixture_replacement :factory_girl, dir: 'spec/factories'
    end

    config.after_initialize do
      if defined?(ActionController::Base)
        ActionController::Base.include(MockleyCrew::MockleyCrewHandled)
      end

      if defined?(ActionController::API)
        ActionController::API.include(MockleyCrew::MockleyCrewHandled)
      end

      if defined?(DeviseController)
        DeviseController.include(MockleyCrew::MockleyCrewHandled)
      end

      if defined?(DeviseTokenAuth)
        DeviseTokenAuth::ApplicationController.include(MockleyCrew::MockleyCrewHandled)
      end
    end
  end
end
