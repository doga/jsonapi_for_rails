module JsonapiForRails::Controller

	module BeforeActions
		module Record

			def self.included receiver
				#$stderr.puts "JsonapiForRails::Controller::RecordFromRequest included into #{receiver}" 
				receiver.send :include, InstanceMethods
				run_macros receiver
			end

			def self.run_macros receiver
				receiver.instance_exec do 
					before_action :jsonapi_require_record, except: [
						:index, 
						:create
					]
					private :jsonapi_require_record
				end
			end

			module InstanceMethods
				def jsonapi_require_record
					#$stderr.puts "JsonapiForRails::Controller::RecordFromRequest#jsonapi_require_record called" 
					if params[:relationship] 
						# relationship action
						@jsonapi_record = model_class.find_by_id params["#{model_class_name.underscore}_id"].to_i
					else
						# CRUD action
						@jsonapi_record = model_class.find_by_id params[:id].to_i
					end
					return if @jsonapi_record

					render_error 401, "Bad request."
				end

			end
		end
	end

end
