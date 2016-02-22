module JsonapiForRails::Controller

	module BeforeActions
		module Include

			def self.included receiver
				receiver.send :include, InstanceMethods
				run_macros receiver
			end

			def self.run_macros receiver
				receiver.instance_exec do 
					before_action :jsonapi_include
					private :jsonapi_include
				end
			end

			module InstanceMethods
				def jsonapi_include
					@jsonapi_include = []
					return unless params[:include] 

					@jsonapi_include = params[:include].split(',').map{|rel| rel.strip.to_sym }
				end

			end
		end
	end

end
