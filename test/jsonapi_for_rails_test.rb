require 'test_helper'

class JsonapiForRails::Test < ActiveSupport::TestCase
  test "Plugin is found" do
    #$stderr.puts "JsonapiForRails::Test" 
    assert_kind_of Module, JsonapiForRails
  end

  test "Plugin adds acts_as_jsonapi_resources class method to controllers" do
    assert ApplicationController.methods.find{|m| m == :acts_as_jsonapi_resources}, "plugin did not modify controller classes"
  end

  test "Controllers that call 'acts_as_jsonapi_resources' have API end-point action methods" do
    require 'set'

    added_instance_methods = %w[
      index show update destroy
      relationship_show relationship_update
      relationship_add relationship_remove
    ].map{|m| m.to_sym}.to_set

    assert added_instance_methods.disjoint?(EmptyController.instance_methods.to_set), 'controller already has some of the methods to be added'

    EmptyController.send :acts_as_jsonapi_resources
    assert added_instance_methods <= EmptyController.instance_methods.to_set, 'plugin did not add all required methods to controller'
  end

  test "Plugin adds 'to_jsonapi_hash' instance method to models" do
    #$stderr.puts "#{ApplicationRecord.instance_methods.reject{|m| m != :to_jsonapi_hash}}" 
    assert_equal 1, ApplicationRecord.instance_methods.reject{|m| m != :to_jsonapi_hash}.size, "plugin did not modify model classes"
  end
end
