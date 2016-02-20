module JsonapiForRails::Model
	extend ActiveSupport::Concern

	included do
		$stderr.puts "JsonapiForRails::Model included into #{self}" 

		# Define instance methods
		class_exec do
			def to_jsonapi_hash
				{data:[]}
			end
		end
	end
end
