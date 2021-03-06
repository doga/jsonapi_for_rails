module JsonapiForRails::Model
	extend ActiveSupport::Concern

	included do
		#$stderr.puts "JsonapiForRails::Model included into #{self}" 

		# Define instance methods
		class_exec do
			def to_jsonapi_hash sparse_fieldset: nil
				#$stderr.puts "JsonapiForRails::Controller::Actions::Object#show called" 

				# attributes
				attrs = attributes.reject do |key, value|
					key =~ /^id$|_id$/
				end
				if sparse_fieldset
					attrs.reject! do |key, value|
						not sparse_fieldset.find{|f| key.to_sym == f}
					end
				end

				# relationships
				relationships = {}
				self.class.reflect_on_all_associations.each do |association|
					if sparse_fieldset
						next unless sparse_fieldset.find{|f| association.name == f}
					end

					relationship = {}
					relationships[association.name] = relationship

					# to-many relationship
					if [
						ActiveRecord::Reflection::HasManyReflection, 
						ActiveRecord::Reflection::HasAndBelongsToManyReflection
						].include? association.class

						relationship[:data] = []
						#$stderr.puts "\nreading relationship '#{association.name}' of class '#{association.class}'" 
						#$stderr.puts "#{@record.send(association.name).inspect}" 
						self.send(association.name).each do |record|
							#$stderr.puts "self.#{association.name}: #{record.class}" 
							relationship[:data] << {
								type: record.class.to_s.underscore.pluralize, # TODO: factor out type generation from class
								id:   record.id.to_s
							}
						end

					# to-one relationship
					elsif [
						ActiveRecord::Reflection::HasOneReflection, 
						ActiveRecord::Reflection::BelongsToReflection
						].include? association.class

						relationship[:data] = nil
						#$stderr.puts "\nreading relationship '#{association.name}' of class '#{association.class}'" 
						#$stderr.puts "#{self.send(association.name).inspect}" 
						if record = self.send(association.name)
							relationship[:data] = {
								type: record.class.to_s.underscore.pluralize, # TODO: factor out type generation from class
								id:   record.id.to_s
							}
						end
					end
				end

				# message
				{
					data: {
						type:          jsonapi_model_type,
						id:            self.id.to_s,
						attributes:    attrs,
						relationships: relationships
					}
				}

			end

			def to_jsonapi_errors_hash
				{
					errors: errors.messages.to_a.reduce([]){ |result, key_value|
						attribute = key_value.first
						messages  = key_value.last
						result + messages.map{ |message|
							{
								detail:     message,
								source: {
									pointer: "/data/attributes/#{attribute}",
								}
							}
						}
					}
				}
			end

			def jsonapi_model_type
				self.class.to_s.underscore.pluralize.to_sym
			end

			private :jsonapi_model_type
		end

	end
end
