module JsonapiForRails::Controller

	module Utils
		module Model
			def self.included receiver
				#$stderr.puts "JsonapiForRails::Controller::ModelUtils included into #{receiver}" 
				receiver.send :include, InstanceMethods
				run_macros receiver
			end

			module InstanceMethods
				def model_class_name
					controller_class_name = "#{self.class}"
					controller_class_name.underscore.split('_')[0..-2].join('_').camelize.singularize
				end

				def model_class
					model_class_name.constantize # Object.const_get model_class_name
				end

				# used in returned JSON API data
				def model_type
					model_class_name.underscore.pluralize
				end
			end

			def self.run_macros receiver
				receiver.instance_exec do 
					private :model_class_name, :model_class, :model_type
				end
			end

		end
	end

end
