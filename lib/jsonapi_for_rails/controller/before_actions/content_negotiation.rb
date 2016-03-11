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
					before_action :jsonapi_content_negotiation, only: [
						:create, 
						:update,
						
						:relationship_update,
						:relationship_add,
						:relationship_remove
					]

					private :jsonapi_content_negotiation
				end
			end

			module InstanceMethods
				def jsonapi_content_negotiation
					jsonapi = ::JsonapiForRails::Controller::Utils::Render::JSONAPI

					# Verify request's Content-Type header #######################
					content_type = request.headers['Content-Type']
					if content_type.nil? or content_type.strip != jsonapi[:content_type]
						# TODO: DEPRECATION WARNING: `:nothing` option is deprecated and will be removed in Rails 5.1. Use `head` method to respond with empty response body. 
						render status: :unsupported_media_type, nothing: true # 415
						return
					end

					# Verify request's Accept header #############################
					loop do
						# Request must have Accept header
						accept = request.headers['Accept']
						break unless accept

						# Accept header's media ranges must match the JSONAPI media type
						acceptable = false
						jsonapi[:media_ranges].each do |media_range|
							index = accept.index media_range
							next unless index

							acceptable = true

							# Generic media range match?
							next unless media_range == jsonapi[:content_type]

							# JSONAPI media type match
							if accept[(index+media_range.size)..-1] =~ /^\s*;/
								# Media type parameter detected
								acceptable = false
								break
							end
						end
						break unless acceptable

						return
					end

					# TODO: DEPRECATION WARNING: `:nothing` option is deprecated and will be removed in Rails 5.1. Use `head` method to respond with empty response body. 
					render :not_acceptable, nothing: true # 406
				end

			end
		end
	end

end
