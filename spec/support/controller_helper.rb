module ControllerHelper
  def formatted_response
    JSON.parse(response.body)
  end
end