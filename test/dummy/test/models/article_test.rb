require 'test_helper'

class ArticleTest < ActiveSupport::TestCase
  test "'to_jsonapi_hash' resource 'id's must be strings (http://jsonapi.org/format/1.0/#document-resource-object-identification)" do
    record = articles(:uk_bank_and_bonuses).to_jsonapi_hash
    #$stderr.puts "#{record.inspect}" 

    # check if all ids are strings
    assert_equal String, record[:data][:id].class, "id is not a string"
    if record[:data][:relationships]
      record[:data][:relationships].each do |rel_name,rel|
        rel = rel[:data]
        rel = [rel] unless rel.class == Array
        rel.each do |r|
          #$stderr.puts "r: #{r.inspect}" 
          assert_equal String, r[:id].class, "id is not a string"
        end
      end
    end
  end

=begin
  test "database has articles"  do
    #$stderr.puts "ArticleTest database has articles" 
    assert Article.all.size>0, "no article"
  end

  test "fixture is readable" do
    #$stderr.puts "ArticleTest fixture is readable" 
    assert articles(:suede_boots)
    assert articles(:suede_boots).tags.include?(tags :fashion)
    refute articles(:suede_boots).tags.include?(tags :business)
  end
=end

end
