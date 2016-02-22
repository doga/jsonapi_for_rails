
# TODO: prefix @status and @json with jsonapi_

require "jsonapi_for_rails/version"
require "jsonapi_for_rails/controller"
require "jsonapi_for_rails/model"

# Add 'acts_as_jsonapi_resources' class method to controllers
ActionController::Metal.send :include, JsonapiForRails::Controller

# Add 'to_jsonapi_hash' instance method to models
ActiveRecord::Base.send      :include, JsonapiForRails::Model

