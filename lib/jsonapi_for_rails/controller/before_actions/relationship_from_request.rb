module JsonapiForRails::Controller

	module BeforeActions
		module RelationshipFromRequest

			def self.included receiver
				receiver.send :include, InstanceMethods
				run_macros receiver
			end

			def self.run_macros receiver
				receiver.instance_exec do 
					before_action :require_relationship, only: [
						:relationship_show,
						:relationship_update,
						:relationship_add,
						:relationship_remove
					]
					private :require_relationship
				end
			end

			module InstanceMethods
				def require_relationship
					#$stderr.puts "JsonapiForRails::Controller::RelationshipFromRequest#require_relationship called" 
					@relationship = received_relationships.first
					return if @relationship

					render_error 401, "Bad request."
				end
			end
		end
	end
end
