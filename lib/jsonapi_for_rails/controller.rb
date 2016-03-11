require "jsonapi_for_rails/controller/utils/model"
require "jsonapi_for_rails/controller/utils/render"
require "jsonapi_for_rails/controller/before_actions/content_negotiation"
require "jsonapi_for_rails/controller/before_actions/sparse_fieldsets"
require "jsonapi_for_rails/controller/before_actions/include"
require "jsonapi_for_rails/controller/before_actions/record"
require "jsonapi_for_rails/controller/before_actions/relationship"
require "jsonapi_for_rails/controller/actions/object"
require "jsonapi_for_rails/controller/actions/relationship"


module JsonapiForRails::Controller
	extend ActiveSupport::Concern

	included do
		#$stderr.puts "JsonapiForRails::Controller included into #{self}" 
	end

	class_methods do
		def acts_as_jsonapi_resources content_negotiation: true #, model: nil
			#$stderr.puts "JsonapiForRails::Controller macro called from #{self}:\n  acts_as_jsonapi_resources(model: #{model or 'nil'})" 

			include JsonapiForRails::Controller::Utils::Model
			include JsonapiForRails::Controller::Utils::Render
			include JsonapiForRails::Controller::BeforeActions::ContentNegotiation if content_negotiation
			include JsonapiForRails::Controller::BeforeActions::SparseFieldsets
			include JsonapiForRails::Controller::BeforeActions::Include
			include JsonapiForRails::Controller::BeforeActions::Record
			include JsonapiForRails::Controller::BeforeActions::Relationship
			include JsonapiForRails::Controller::Actions::Object
			include JsonapiForRails::Controller::Actions::Relationship

		end
	end
end
