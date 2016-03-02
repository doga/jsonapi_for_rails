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

					@jsonapi_status = 200
					@jsonapi_json = ['development', 'test'].include?(Rails.env) ? JSON.pretty_generate(object) : JSON.generate(object)
					@jsonapi_content_type = JSONAPI[:content_type]

					render(
						plain:        @jsonapi_json,
						#json:         @jsonapi_json, 
						status:       @jsonapi_status
						#content_type: @jsonapi_content_type
					)
					response.headers['Content-Type'] = @jsonapi_content_type
				end

				def render_error status, title
					@jsonapi_status = status
					object = {
						errors: [
							{title: title}
						]
					}
					@jsonapi_json = ['development', 'test'].include?(Rails.env) ? JSON.pretty_generate(object) : JSON.generate(object)
					@jsonapi_content_type = JSONAPI[:content_type]

					render(
						plain:        @jsonapi_json,
						#json:         @jsonapi_json, 
						status:       @jsonapi_status
						#content_type: @jsonapi_content_type
					)
					response.headers['Content-Type'] = @jsonapi_content_type
				end
			end

		end
	end
	
end
