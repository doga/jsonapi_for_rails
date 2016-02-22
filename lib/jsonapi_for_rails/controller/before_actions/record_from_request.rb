module JsonapiForRails::Controller

	module BeforeActions
		module RecordFromRequest

			def self.included receiver
				#$stderr.puts "JsonapiForRails::Controller::RecordFromRequest included into #{receiver}" 
				receiver.send :include, InstanceMethods
				run_macros receiver
			end

			def self.run_macros receiver
				receiver.instance_exec do 
					before_action :require_record, except: [
						:index, 
						:create
					]
					private :require_record
				end
			end

			module InstanceMethods
				def require_record
					#$stderr.puts "JsonapiForRails::Controller::RecordFromRequest#require_record called" 
					if params[:relationship] 
						# relationship action
						@jsonapi_record = model_class.find_by_id params["#{model_class_name.downcase}_id"].to_i
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
