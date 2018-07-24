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