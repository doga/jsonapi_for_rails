
# TODO: JSONAPI: id of resource object is a string
# TODO: JSONAPI: adding optional members to documents ('jsonapi', 'meta')
# TODO: JSONAPI: return conformant HTTP status codes
# TODO: JSONAPI: conformant and rich 'errors' member
# TODO: JSONAPI: content negotiation
# TODO: JSONAPI: apply sparse fieldsets _after_ including related resources
# TODO: JSONAPI: should included resources list their relationships (which links to primary object)?
# TODO: JSONAPI: do not support Client-Generated IDs?
# TODO: JSONAPI: Location header

# TODO: README.md: double-check the installation instructions
# TODO: README.md: better describe @jsonapi_relationship (what can it contain besides 'definition'?)
# TODO: README.md: describe @jsonapi_include?
# TODO: README.md: describe @jsonapi_sparse_fieldsets?


require "jsonapi_for_rails/version"
require "jsonapi_for_rails/controller"
require "jsonapi_for_rails/model"

# Add 'acts_as_jsonapi_resources' class method to controllers
ActionController::Metal.send :include, JsonapiForRails::Controller

# Add 'to_jsonapi_hash' instance method to models
ActiveRecord::Base.send      :include, JsonapiForRails::Model

