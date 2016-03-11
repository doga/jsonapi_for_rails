
# TODO: content negotiation tests
# TODO: apply sparse fieldsets _after_ including related resources
# TODO: Location header
# TODO: add 'links' to documents 
# TODO: return conformant HTTP status codes
# TODO: options for 'acts_as_jsonapi_resources'? example: {content_negotiation: false}
# TODO: adding optional members to documents ('jsonapi', 'meta')
# TODO: conformant and rich 'errors' member
# TODO: should included resources list their relationships (which links to primary object)?
# TODO: do not support Client-Generated IDs?

# TODO: README.md: double-check the installation instructions
# TODO: README.md: describe @jsonapi_include ?
# TODO: README.md: describe @jsonapi_sparse_fieldsets ?


require "jsonapi_for_rails/version"
require "jsonapi_for_rails/controller"
require "jsonapi_for_rails/model"

# Add 'acts_as_jsonapi_resources' class method to controllers
ActionController::Metal.send :include, JsonapiForRails::Controller

# Add 'to_jsonapi_hash' instance method to models
ActiveRecord::Base.send      :include, JsonapiForRails::Model

