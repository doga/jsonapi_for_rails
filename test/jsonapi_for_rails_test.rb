require 'test_helper'

class JsonapiForRails::Test < ActiveSupport::TestCase
  test "Plugin is found" do
    #$stderr.puts "JsonapiForRails::Test" 
    assert_kind_of Module, JsonapiForRails
  end

  test "Models have to_jsonapi_hash method" do
    #$stderr.puts "#{ApplicationRecord.instance_methods.reject{|m| m != :to_jsonapi_hash}}" 
    assert_equal 1, ApplicationRecord.instance_methods.reject{|m| m != :to_jsonapi_hash}.size, "plugin did not modify model classes"
  end
end
