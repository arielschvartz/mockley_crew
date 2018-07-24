ActionController::API.include(MockleyCrew::MockleyCrewHandled)

if defined?(DeviseController)
  DeviseController.include(MockleyCrew::MockleyCrewHandled)
end

if defined?(DeviseTokenAuth)
  DeviseTokenAuth::ApplicationController.include(MockleyCrew::MockleyCrewHandled)
end