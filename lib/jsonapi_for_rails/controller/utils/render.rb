require 'json'

module JsonapiForRails::Controller

	module Utils
		module Render
			def self.included receiver
				receiver.send :include, InstanceMethods
				run_macros receiver
			end

			JSONAPI = {
				specification: 'http://jsonapi.org/format/',
				content_type: 'application/vnd.api+json',
				media_range: [
					'*/*',
					'application/*',
					'application/vnd.api+json'
				]
			}.freeze

			def self.run_macros receiver
				receiver.instance_exec do 
					private :jsonapi_render, :jsonapi_render_errors
				end
			end

			module InstanceMethods
				def jsonapi_render object
					# Status code
					@jsonapi_status = 200

					# Generate json
					@jsonapi_json = JSON.generate(object)

					# Render
					render(
						plain:        @jsonapi_json,
						status:       @jsonapi_status
					)

					# Set content type
					@jsonapi_content_type = JSONAPI[:content_type]
					response.headers['Content-Type'] = @jsonapi_content_type
				end

				def jsonapi_render_errors status, argument
					# Status code
					@jsonapi_status = status

					# Generate json
					if argument.kind_of? Hash
						message = argument
					elsif argument.kind_of? Array
						message = {
							errors: argument
						}
					else
						message = {
							errors: [
								{detail: argument.to_s}
							]
						}
					end

					@jsonapi_json = JSON.generate(message)

					# Render
					render(
						plain:        @jsonapi_json,
						status:       @jsonapi_status
					)

					# Set content type
					@jsonapi_content_type = JSONAPI[:content_type]
					response.headers['Content-Type'] = @jsonapi_content_type
				end
			end

		end
	end
	
end
