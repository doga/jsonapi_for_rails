module JsonapiForRails::Controller

	module BeforeActions
		module Links

			def self.included receiver
				receiver.send :include, InstanceMethods
				run_macros receiver
			end

			def self.run_macros receiver
				receiver.instance_exec do 
					before_action :jsonapi_links
					private :jsonapi_links
				end
			end

			module InstanceMethods

				# Enable links in returned documents
				def jsonapi_links
					@jsonapi_links = true
				end

			end
		end
	end

end
