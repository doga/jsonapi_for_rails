
# TODO: send pull request to add jsonapi_for_rails to JSON API implementations list (http://jsonapi.org/implementations/)
# TODO: double-check the installation instructions in README.md
# TODO: 'Contributing' section in README.md

require "jsonapi_for_rails/version"
require "jsonapi_for_rails/controller"
require "jsonapi_for_rails/model"

# Add 'acts_as_jsonapi_resources' class method to controllers
ActionController::Metal.send :include, JsonapiForRails::Controller

# Add 'to_jsonapi_hash' instance method to models
ActiveRecord::Base.send      :include, JsonapiForRails::Model

