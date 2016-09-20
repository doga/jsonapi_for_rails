module JsonapiForRails::Controller

	module Actions
		module Object
			def self.included receiver
				receiver.send :include, InstanceMethods
				run_macros receiver
			end

			module InstanceMethods
				# TODO: pagination
				def index
					@json = {data: []}
					jsonapi_model_class.all.each do |record|
						@json[:data] << {
							type: record.class.to_s.underscore.pluralize, # TODO: factor out type generation from class
							id:   record.id.to_s
						}
					end

					# Links
					if @jsonapi_links
						@json[:links] = {
							self: self.send(
								"#{jsonapi_model_type}_path" # TODO: factor out
							)
						}
					end

					jsonapi_render @json
				end

				# implements Create and Update operations
				def create

					# attributes
					begin
						attrs = jsonapi_received_attributes
						if attrs
							if @jsonapi_record
								# update
								@jsonapi_record.update! attrs
							else
								# create
								@jsonapi_record = jsonapi_model_class.new attrs
								@jsonapi_record.save!
							end
						end
					rescue NameError => e
						jsonapi_render_errors 500, "Model class not found."
						return
					rescue 
						jsonapi_render_errors 500, @jsonapi_record.to_jsonapi_errors_hash
						return
					end

					# relationships
					jsonapi_received_relationships.each do |relationship|
						begin
								# to-one
								if relationship[:definition][:type] == :to_one
									@jsonapi_record.send :"#{relationship[:definition][:name]}=", relationship[:params][:data]
									next
								end

								# to-many
								@jsonapi_record.send(relationship[:definition][:name]).send :clear # initialize the relation
								
								relationship[:params][:data].each do |item|
									object = relationship[:receiver][:class].find_by_id item[:id]
									@jsonapi_record.send(relationship[:definition][:name]).send :<<, object
								end

						rescue 
							# Should not happen
							jsonapi_render_errors 500, "Relationship could not be created."
							return
						end
					end

					show
				end

				def show
					# Attributes and relationships
					@json = @jsonapi_record.to_jsonapi_hash(
						 sparse_fieldset: @jsonapi_sparse_fieldsets[jsonapi_model_type]
					)

					# Links
					if @jsonapi_links

						# Current resource
						@json[:data][:links] = {
							self: self.send(
								"#{jsonapi_model_type.to_s.singularize}_path", # TODO: factor out
								@jsonapi_record.id
							)
						}

						# Related resources
						@json[:data][:relationships].each do |rel_name, rel|
							rel[:links] = {
								self: "#{@json[:data][:links][:self]}/relationships/#{rel_name}"
							}
						end
					end

					#$stderr.puts "#{@json}" 

					# Include resources
					# TODO: relationship paths when including resources (http://jsonapi.org/format/1.0/#fetching-includes)
					if @jsonapi_include and @json[:data][:relationships]
						@json[:included] = []
						@jsonapi_include.each do |rel_name|
							rel = @json[:data][:relationships][rel_name]
							next unless rel
							rel = rel[:data]
							next unless rel
							rel = [rel] if rel.kind_of?(Hash)
							rel.each do |r|
								type = r[:type].to_sym
								klass = nil
								begin
									klass = r[:type].singularize.camelize.constantize
								rescue NameError => e
									next									
								end
								r = klass.find_by_id r[:id]
								next unless r

								# Attributes and relationships
								r = r.to_jsonapi_hash(
									sparse_fieldset: @jsonapi_sparse_fieldsets[type]
								)

								# Links
								if @jsonapi_links
									r[:links] = {
										self: self.send(
											"#{r[:data][:type].to_s.singularize}_path", # TODO: factor out
											r[:data][:id]
										)
									}
								end

								@json[:included] << r[:data]
							end
						end
					end

					jsonapi_render @json
				end

				def update
					create
				end

				def destroy
					jsonapi_render_errors 500, "Not implemented."
				end

				# private

				# Extracts record attributes from received params. 
				# Use this for creating/updating a database record.
				# Note that relationships (has_one associations etc) are filtered out
				# but are still available in the original params.
				def jsonapi_received_attributes
					begin
						params.require(
							:data
						).require(
							:attributes
						).permit(
							*jsonapi_model_class.attribute_names
						).reject do |key, value|
							# ignore automatically generated attributes
							%w(
								id 
								created_at created_on 
								updated_at updated_on
							).include?(
								key.to_s
							) or 

							# ignore reference attributes
							key.to_s =~ /_id$/
						end
					rescue  ActionController::ParameterMissing => e
						nil
					end
				end

				# Definitions of all relationships for current model
				def jsonapi_relationships
					jsonapi_model_class.reflect_on_all_associations.collect do |association|
						#type = nil

						type = :to_one if [
							ActiveRecord::Reflection::HasOneReflection, 
							ActiveRecord::Reflection::BelongsToReflection
						].include? association.class

						type = :to_many if [
							ActiveRecord::Reflection::HasManyReflection, 
							ActiveRecord::Reflection::HasAndBelongsToManyReflection
						].include? association.class

						next unless type

						{
							name: association.name,
							type: type,
							receiver: {
								type:  association.klass.to_s.underscore.pluralize.to_sym,
								class: association.klass.to_s.constantize
							}
						}
					end.compact
				end

				# TODO: define a separate method for relationship actions (i.e. when params[:relationship] != nil)
				def jsonapi_received_relationships
					# Relationship definitions for current model
					rels = jsonapi_relationships

					# Consider only current relationship for relationship actions
					# (params[:relationship] contains the relationship name)
					if params[:relationship] 

						rels.select! do |rel|
							rel[:name].to_sym == params[:relationship].to_sym
						end

						# If no relationship is received, then return the definition only
						if request.method == "GET"
							return rels.collect do |rel|
								{definition: rel}
							end
						end

					end

					rels.collect do |relationship|
						begin
							received_params = nil

							# Relationship action
							if params[:relationship]
								received_params =  params.permit({
									data: [
										:type, :id
									]
								})

							# Object action
							else
								received_params =  params.require( 
									:data
								).require(
									:relationships
								).require(
									relationship[:name]
								).permit({
									data: [
										:type, :id
									]
								})
							end
							# => {"data"=>{"type"=>"users", "id"=>1}}                                         # sample value for a to-one association
							# => {"data"=>[{"type"=>"properties", "id"=>1}, {"type"=>"properties", "id"=>2}]} # sample value for a to-many association

							# is received data conformant to the database schema? 
							conformant = true
							loop do
								# to-many
								if received_params[:data].kind_of? Array
									if relationship[:type] != :to_many
										conformant = false
										break
									end
									received_params[:data].each do |item|
										next if item[:type].to_sym == relationship[:receiver][:type]
										conformant = false
										break
									end
									break
								end

								# to-one
								if relationship[:type] != :to_one
									conformant = false
									break
								end
								conformant = false unless received_params[:data][:type].to_sym == relationship[:receiver][:type]

								break
							end
							next unless conformant

							{
								definition: relationship,
								params:     received_params
							}
						rescue ActionController::ParameterMissing => e

							# nil assignment to to-one relationship?
							if relationship[:type] == :to_one
								begin
									if params[:relationship] # relationship action
										received_params =  params.permit(
											:data
										)
									else
										received_params =  params.require( 
											:data
										).require(
											:relationships
										).require(
											relationship[:name]
										).permit(
											:data
										)
									end

									# received nil?
									next if received_params[:data] # TODO: should return error to client?

									next {
										definition: relationship,
										params:     received_params
									}
								rescue ActionController::ParameterMissing => e
								end
							end

							nil
						end
					end.compact
				end

			end

			def self.run_macros receiver
				receiver.instance_exec do 
					private :jsonapi_received_attributes
					private :jsonapi_relationships
					private :jsonapi_received_relationships
				end
			end

		end
	end

end
