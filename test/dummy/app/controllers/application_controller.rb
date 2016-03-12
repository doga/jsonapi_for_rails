class ApplicationController < ActionController::Base
  # Prevent CSRF attacks by raising an exception.
  # For APIs, you may want to use :null_session instead.
  #protect_from_forgery with: :exception

  acts_as_jsonapi_resources(
    content_negotiation: false,
    links:               true
  )

end
