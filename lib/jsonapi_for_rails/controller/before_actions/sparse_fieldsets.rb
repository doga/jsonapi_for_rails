module JsonapiForRails::Controller

	module BeforeActions
		module SparseFieldsets

			def self.included receiver
				receiver.send :include, InstanceMethods
				run_macros receiver
			end

			def self.run_macros receiver
				receiver.instance_exec do 
					before_action :jsonapi_sparse_fieldsets
					private :jsonapi_sparse_fieldsets
				end
			end

			module InstanceMethods
				def jsonapi_sparse_fieldsets
					@jsonapi_sparse_fieldsets = {}
					return unless params[:fields]

					params[:fields].each do |resources_name, fields|
						resources_name = resources_name.to_sym
						fields = 
							fields.split(',').
							map{|field| field.strip.to_sym }.
							select{|e| e =~ /^[A-Za-z1-9_]+$/} # BUG: selector too restrictive
						next if fields.size.zero?
						@jsonapi_sparse_fieldsets[resources_name] = fields#.join(',')
					end 

				end

			end
		end
	end

end
