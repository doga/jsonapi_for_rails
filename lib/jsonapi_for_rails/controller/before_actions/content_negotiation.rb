module JsonapiForRails::Controller

	module BeforeActions
		module ContentNegotiation

			def self.included receiver
				#$stderr.puts "JsonapiForRails::Controller::RecordFromRequest included into #{receiver}" 
				receiver.send :include, InstanceMethods
				run_macros receiver
			end

			def self.run_macros receiver
				receiver.instance_exec do 
					before_action :content_negotiation
					private :content_negotiation
				end
			end

			module InstanceMethods
				def content_negotiation
					#$stderr.puts "#{request.headers}" 
					# TODO: content negotiation
					return 
					render_error 401, "Bad request."
				end

			end
		end
	end

end
