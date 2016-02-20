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
					$stderr.puts "JsonapiForRails::Controller::Actions::Relationship#relationship_show called" 
					rel = @record.send @relationship[:definition][:name]

					@json = nil
					if @relationship[:definition][:type] == :to_one
						@json = {
							type: @relationship[:definition][:receiver][:type],
							id:   rel.id
						}
					elsif @relationship[:definition][:type] == :to_many
						@json = rel.collect do |r|
							{
								type: @relationship[:definition][:receiver][:type],
								id:   r.id
							}
						end
					end
					@json = {data: @json}

					render_json @json
				end

				# PATCH
				def relationship_update
					if @relationship[:definition][:type] == :to_many
						render_error 403, 'Replacing all members of a to-many relationship is forbidden.'
						return
					end

					related = nil
					if @relationship[:params][:data]
						related = @relationship[:definition][:receiver][:class].find_by_id(
							@relationship[:params][:data][:id]
						)
						unless related
							render_error 403, 'Record not found.'
							return
						end
					end

					@record.send :"#{@relationship[:definition][:name]}=", related
					@record.save
				end

				# POST for to-many relations only
				def relationship_add
					unless @relationship[:definition][:type] == :to_many
						render_error 403, 'Operation allowed for to-many relationships only.'
						return
					end
					
					records = @relationship[:params][:data].collect do |record|
						record = @relationship[:definition][:receiver][:class].find_by_id(
							record[:id]
						)
						unless record
							render_error 403, "Non-existing record #{record.inspect}."
							return
						end
						record
					end

					records.each do |record|
						@record.send(@relationship[:definition][:name]) << record
					end
				end

				# DELETE for to-many relations only
				def relationship_remove
					unless @relationship[:definition][:type] == :to_many
						render_error 403, 'Operation allowed for to-many relationships only.'
						return
					end
					
					records = @relationship[:params][:data].collect do |record|
						record = @relationship[:definition][:receiver][:class].find_by_id(
							record[:id]
						)
						unless record
							render_error 403, "Non-existing record #{record.inspect}."
							return
						end
						record
					end

					records.each do |record|
						@record.send(@relationship[:definition][:name]).delete record
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
