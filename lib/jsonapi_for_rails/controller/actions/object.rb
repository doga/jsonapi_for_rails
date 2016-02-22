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
					model_class.all.each do |record|
						@json[:data] << {
							type: record.class.to_s.underscore.pluralize, # TODO: factor out type generation from class
							id:   record.id
						}
					end
					render_json @json
				end

				# implements Create and Update operations
				def create
					begin
						# attributes
						attrs = received_attributes
						if attrs
							if @jsonapi_record
								# update
								@jsonapi_record.update! attrs
							else
								# create
								@jsonapi_record = model_class.create! attrs
							end
						end

						# relationships
						received_relationships.each do |relationship|
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
						end
					rescue NameError => e

						# error when creating record			
						render_error 500, "Model class not found."
						return
					rescue 
						# error when creating relationship?
						@jsonapi_record.destroy if @jsonapi_record 

						render_error 500, "Record could not be created."
						return
					end
					show
				end

				def show
					@json = @jsonapi_record.to_jsonapi_hash(
						@jsonapi_sparse_fieldsets[model_type]
					)
					$stderr.puts "#{@json}" 

					# Include resources
					# TODO: relationship paths when including resources (http://jsonapi.org/format/1.0/#fetching-includes)
					if @jsonapi_include and @json[:data][:relationships]
						@json[:include] = []
						@jsonapi_include.each do |rel_name|
							rel = @json[:data][:relationships][rel_name]
							next unless rel
							$stderr.puts "rel: #{rel}" 
							rel = rel[:data]
							next unless rel
							rel = [rel] if rel.kind_of?(Hash)
							rel.each do |r|
								$stderr.puts "including: #{r}" 
								type = r[:type].to_sym
								$stderr.puts "@jsonapi_sparse_fieldsets[#{type}]: #{@jsonapi_sparse_fieldsets[type]}" 
								klass = nil
								begin
									klass = r[:type].singularize.camelize.constantize
								rescue NameError => e
									next									
								end
								r = klass.find_by_id r[:id]
								next unless r

								@json[:include] << r.to_jsonapi_hash(
									@jsonapi_sparse_fieldsets[type]
								)
							end
						end
					end

					render_json @json
				end

				def update
					create
				end

				def destroy
					render_error 500, "Not implemented."
				end

				# private

				# Extracts record attributes from received params. 
				# Use this for creating/updating a database record.
				# Note that relationships (has_one associations etc) are filtered out
				# but are still available in the original params.
				def received_attributes
					begin
						params.require(
							:data
						).require(
							:attributes
						).permit(
							*model_class.attribute_names
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

				def relationships
					model_class.reflect_on_all_associations.collect do |association|
						type = nil

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
								type: association.klass.to_s.underscore.pluralize,
								class: association.klass.to_s.constantize
							}
						}
					end.compact
				end

				def received_relationships
					rels = relationships
					if params[:relationship] # only one relationship received for relationship action
						rels.select! do |rel|
							rel[:name].to_sym == params[:relationship].to_sym
						end
						if request.method == "GET"
							# no relationship received, return definition only
							return rels.collect do |rel|
								{definition: rel}
							end
						end
					end
					rels.collect do |relationship|
						begin
							received_params = nil
							if params[:relationship]
								received_params =  params.permit({
									data: [
										:type, :id
									]
								})
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
										next if item[:type] == relationship[:receiver][:type]
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
								conformant = false unless received_params[:data][:type] == relationship[:receiver][:type]

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
					private :received_attributes
					private :relationships
					private :received_relationships
				end
			end

		end
	end

end
