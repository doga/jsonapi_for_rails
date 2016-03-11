module JsonapiForRails::Controller

	module Actions
		module Relationship
			def self.included receiver
				receiver.send :include, InstanceMethods
				run_macros receiver
			end

			module InstanceMethods
				# GET
				def relationship_show
					#$stderr.puts "JsonapiForRails::Controller::Actions::Relationship#relationship_show called" 
					rel = @jsonapi_record.send @jsonapi_relationship[:definition][:name]

					@json = nil
					if @jsonapi_relationship[:definition][:type] == :to_one
						@json = {
							type: @jsonapi_relationship[:definition][:receiver][:type],
							id:   rel.id.to_s
						}
					elsif @jsonapi_relationship[:definition][:type] == :to_many
						@json = rel.collect do |r|
							{
								type: @jsonapi_relationship[:definition][:receiver][:type],
								id:   r.id.to_s
							}
						end
					end
					@json = {data: @json}

					render_json @json
				end

				# PATCH
				def relationship_update
					if @jsonapi_relationship[:definition][:type] == :to_many
						render_errors 403, 'Replacing all members of a to-many relationship is forbidden.'
						return
					end

					related = nil
					if @jsonapi_relationship[:params][:data]
						related = @jsonapi_relationship[:definition][:receiver][:class].find_by_id(
							@jsonapi_relationship[:params][:data][:id]
						)
						unless related
							render_errors 403, 'Record not found.'
							return
						end
					end

					@jsonapi_record.send :"#{@jsonapi_relationship[:definition][:name]}=", related
					@jsonapi_record.save
				end

				# POST for to-many relations only
				def relationship_add
					unless @jsonapi_relationship[:definition][:type] == :to_many
						render_errors 403, 'Operation allowed for to-many relationships only.'
						return
					end
					
					records = @jsonapi_relationship[:params][:data].collect do |record|
						record = @jsonapi_relationship[:definition][:receiver][:class].find_by_id(
							record[:id]
						)
						unless record
							render_errors 403, "Non-existing record #{record.inspect}."
							return
						end
						record
					end

					records.each do |record|
						@jsonapi_record.send(@jsonapi_relationship[:definition][:name]) << record
					end
				end

				# DELETE for to-many relations only
				def relationship_remove
					unless @jsonapi_relationship[:definition][:type] == :to_many
						render_errors 403, 'Operation allowed for to-many relationships only.'
						return
					end
					
					records = @jsonapi_relationship[:params][:data].collect do |record|
						record = @jsonapi_relationship[:definition][:receiver][:class].find_by_id(
							record[:id]
						)
						unless record
							render_errors 403, "Non-existing record #{record.inspect}."
							return
						end
						record
					end

					records.each do |record|
						@jsonapi_record.send(@jsonapi_relationship[:definition][:name]).delete record
					end
				end
			end

			def self.run_macros receiver
				receiver.instance_exec do 
				end
			end
		end
	end

end
