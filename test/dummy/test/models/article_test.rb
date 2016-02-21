require 'test_helper'

class ArticleTest < ActiveSupport::TestCase
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
end
