module JsonapiForRails::Controller

	module BeforeActions
		module Relationship

			def self.included receiver
				receiver.send :include, InstanceMethods
				run_macros receiver
			end

			def self.run_macros receiver
				receiver.instance_exec do 
					before_action :jsonapi_require_relationship, only: [
						:relationship_show,
						:relationship_update,
						:relationship_add,
						:relationship_remove
					]
					private :jsonapi_require_relationship
				end
			end

			module InstanceMethods
				def jsonapi_require_relationship
					#$stderr.puts "@@@@@@@@@@@@@@ jsonapi_require_relationship" 
					#log_request
					#$stderr.puts "#{jsonapi_received_relationships.inspect}" 

					@jsonapi_relationship = jsonapi_received_relationships.first
					return if @jsonapi_relationship

					jsonapi_render_errors 401, "Bad request."
				end
			end
		end
	end
end
