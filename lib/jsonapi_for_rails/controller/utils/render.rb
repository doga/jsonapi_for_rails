module JsonapiForRails::Controller

	module Utils
		module Render
			def self.included receiver
				receiver.send :include, InstanceMethods
				run_macros receiver
			end

			JSONAPI = {
				specification: 'http://jsonapi.org/format/',
				content_type: 'application/vnd.api+json'
			}.freeze

			def self.run_macros receiver
				receiver.instance_exec do 
					private :render_json, :render_error
				end
			end

			module InstanceMethods
				def render_json object
					unless object
						render_error 500, 'No message specified.'
						return
					end

					@status = 200
					@json = object
					@content_type = JSONAPI[:content_type]

					render(
						json:         @json, 
						status:       @status, 
						content_type: @content_type
					)
				end

				def render_error status, title
					@status = status
					@json = {
						errors: [
							{title: title}
						]
					}
					@content_type = JSONAPI[:content_type]

					render(
						json:         @json, 
						status:       @status, 
						content_type: @content_type
					)
				end
			end

		end
	end
	
end
