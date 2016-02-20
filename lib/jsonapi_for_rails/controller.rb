require "jsonapi_for_rails/controller/utils/model"
require "jsonapi_for_rails/controller/utils/render"
require "jsonapi_for_rails/controller/before_actions/record_from_request"
require "jsonapi_for_rails/controller/before_actions/relationship_from_request"
require "jsonapi_for_rails/controller/actions/object"
require "jsonapi_for_rails/controller/actions/relationship"


module JsonapiForRails::Controller
	extend ActiveSupport::Concern

	included do
		$stderr.puts "JsonapiForRails::Controller included into #{self}" 
	end

	class_methods do
		def acts_as_jsonapi_resources model: nil
			$stderr.puts "JsonapiForRails::Controller macro called from #{self}:\n  acts_as_jsonapi_resources(model: #{model or 'nil'})" 

			include JsonapiForRails::Controller::Utils::Model
			include JsonapiForRails::Controller::Utils::Render
			include JsonapiForRails::Controller::BeforeActions::RecordFromRequest
			include JsonapiForRails::Controller::BeforeActions::RelationshipFromRequest
			include JsonapiForRails::Controller::Actions::Object
			include JsonapiForRails::Controller::Actions::Relationship

		end
	end
end
