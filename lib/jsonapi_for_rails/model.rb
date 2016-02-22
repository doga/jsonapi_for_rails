module JsonapiForRails::Model
	extend ActiveSupport::Concern

	included do
		#$stderr.puts "JsonapiForRails::Model included into #{self}" 

		# Define instance methods
		class_exec do
			def to_jsonapi_hash
				#$stderr.puts "JsonapiForRails::Controller::Actions::Object#show called" 

				# attributes
				attrs = attributes.reject do |key, value|
					key =~ /^id$|_id$/
				end

				# relationships
				relationships = {}
				self.class.reflect_on_all_associations.each do |association|
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
								id:   record.id
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
								id:   record.id
							}
						end
					end
				end

				# message
				{
					meta: {
						generated_by_class: "#{self.class}"
					},
					data: {
						type:       model_type,
						id:         self.id,

						attributes: attrs,

						relationships: relationships
					}
				}

			end

			def model_type
				"#{self.class}".underscore.pluralize
			end

			private :model_type
		end

	end
end
