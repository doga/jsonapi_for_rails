require 'test_helper'

# TODO: how to set the damn Content-Type header in requests? 

class ArticlesControllerTest < ActionDispatch::IntegrationTest
  

  test "'@jsonapi_record' is set and '@jsonapi_relationship' is not set when inside 'show' action" do
    #skip
    get "#{article_path articles(:uk_bank_and_bonuses)}"
    record = @controller.instance_variable_get('@jsonapi_record')
    relationship = @controller.instance_variable_get('@jsonapi_relationship')

    assert record
    assert record.class == @controller.send(:jsonapi_model_class)
    assert record.id == articles(:uk_bank_and_bonuses).id

    refute relationship
  end

  test "'@jsonapi_record' and '@jsonapi_relationship' are set when inside 'relationship_show' action" do
    #skip
    get "#{article_path articles(:uk_bank_and_bonuses)}/relationships/author"
    record = @controller.instance_variable_get('@jsonapi_record')
    relationship = @controller.instance_variable_get('@jsonapi_relationship')

    assert record
    assert record.id == articles(:uk_bank_and_bonuses).id

    assert relationship
    assert relationship[:definition]
    refute relationship[:params]
    #$stderr.puts "@jsonapi_relationship: #{relationship.inspect}" 
  end

  test "'@jsonapi_record' and '@jsonapi_relationship' are set when inside 'relationship_update' action" do
    #skip
    patch(
      "#{article_path articles(:uk_bank_and_bonuses)}/relationships/author",
      xhr: true,
      params: {
        data: {
          type: authors(:press_association).class.to_s.underscore.pluralize,
          id:   authors(:press_association).id
        }
      }
    )
    record = @controller.instance_variable_get('@jsonapi_record')
    relationship = @controller.instance_variable_get('@jsonapi_relationship')

    assert record
    assert record.id == articles(:uk_bank_and_bonuses).id

    assert relationship
    assert relationship[:definition]
    assert relationship[:params]
    #$stderr.puts "relationship[:params][:data]: #{relationship[:params][:data].inspect}" 
    #$stderr.puts "relationship[:params][:data][:type]: #{relationship[:params][:data][:type].inspect}" 
    #$stderr.puts "@jsonapi_relationship: #{relationship.inspect}" 
  end


  test "get list of articles" do
    #skip
    # BUG: ArticlesController#index is not called
    assert_no_difference 'Article.count' do
      get articles_path 
    end
    #$stderr.puts "#{@response.inspect}" 
    #$stderr.puts "response.body: #{response.body}" 

    assert_response :success
    json = JSON.parse response.body, symbolize_names: true
    #$stderr.puts JSON.pretty_generate json

    assert          json,               "no json response"
    refute          json[:errors],      'response is error'
    assert_kind_of  Array, json[:data],        "response is not articles"
    json[:data].each do |data|
      assert_equal 0, data.reject{|k,v| [:type, :id].include? k }.size, "attribute is other than :type, :id"
      assert_equal 'articles', data[:type], "resource is not articles"
    end

  end

  test "get article"  do
    #skip
    get article_path(articles(:uk_bank_and_bonuses)), {
      params: {
        'fields[articles]' => 'title,author',
        include:              'author',
        'fields[authors]'  => 'name'
      },
      headers: {},
      xhr: true
    }
    assert_response :success
    #$stderr.puts "#{response.body}" 
    json = JSON.parse response.body, symbolize_names: true
    #$stderr.puts JSON.pretty_generate json
    
    assert json
    assert json[:data]
    assert_kind_of String, json[:data][:type]
    assert_kind_of String, json[:data][:id]
    assert_kind_of Hash, json[:data][:attributes]
    assert_kind_of Hash, json[:data][:relationships]
  end

  test "get related author" do
    get "#{article_path articles(:uk_bank_and_bonuses)}/relationships/author"

    assert_response :success
    #$stderr.puts "#{response.body}" 
    json = JSON.parse response.body, symbolize_names: true
    #$stderr.puts JSON.pretty_generate json
    assert_equal 'authors', json[:data][:type], "bad type"
    author = Author.find(json[:data][:id])
    assert author
    #$stderr.puts "#{author.inspect}" 
  end


  test "set related author" do
    # verify that author isn't press_association
    get "#{article_path articles(:suede_boots)}/relationships/author"
    assert_response :success
    #$stderr.puts "current author: #{response.body}" 
    assert_nil(response.body.index authors(:press_association).id.to_s)

    # set author
    #$stderr.puts "new author: #{authors(:press_association).inspect}" 
    patch(
      "#{article_path articles(:suede_boots)}/relationships/author",
      headers: {
        'HTTP_ACCEPT' => 'application/vnd.api+json'
      },
      xhr: true,
      params: {
        data: {
          type: :authors,
          id:    authors(:press_association).id.to_s
        }
      }
    )

    assert_response :success

    # verify that author is press_association
    get "#{article_path articles(:suede_boots)}/relationships/author"
    #$stderr.puts "current author: #{response.body}" 
    assert_response :success
    assert(response.body.index authors(:press_association).id.to_s)
    
  end

  test "get related tags" do
    #skip
    get "#{article_path articles(:uk_bank_and_bonuses)}/relationships/tags"

    assert_response :success
    #$stderr.puts "#{response.body}" 
    json = JSON.parse response.body, symbolize_names: true
    #$stderr.puts JSON.pretty_generate json

    assert          json,               "no json response"
    refute          json[:errors],      'response is error'
    assert_kind_of  Array, json[:data],        "response is not articles"
    json[:data].each do |data|
      assert_equal 0, data.reject{|k,v| [:type, :id].include? k }.size, "attribute is other than :type, :id"
      assert_equal 'tags', data[:type], "resource is not tags"
    end
  end

=begin
  test "set related tags" do
    ##skip
    patch(
      "#{article_path articles(:suede_boots)}/relationships/tags",
      xhr: true,
      params: {
        data: [
          {
            type: :tags,
            id: tags(:business).id.to_s
          }
        ]
      }
    )

    #$stderr.puts "#{response.body}" 

    assert_response :success
    json = JSON.parse response.body, symbolize_names: true
    #$stderr.puts "#{json}" 
    
  end
=end

  test "add related tags" do
    #skip
    
    # verify that business tag has not yet been added #####################
    get "#{article_path articles(:suede_boots)}/relationships/tags"

    assert_response :success
    #$stderr.puts "#{response.body}" 
    json = JSON.parse response.body, symbolize_names: true
    #$stderr.puts "business tag id: #{tags(:business).id}" 
    #$stderr.puts "article tags: #{JSON.pretty_generate json}"

    assert          json,               "no json response"
    refute          json[:errors],      'response is error'
    assert_kind_of  Array, json[:data],        "response is not articles"
    refute          json[:data].detect{|item| item[:id] == tags(:business).id.to_s and item[:type] == 'tags'}

    # add business tag ################################
    post(
      "#{article_path articles(:suede_boots)}/relationships/tags",
      xhr: true,
      params: {
        data: [
          {
            type: :tags,
            id: tags(:business).id.to_s
          }
        ]
      }
    )

    #$stderr.puts "#{response.status} #{response.body}" 

    assert_response :success
    #$stderr.puts "#{json}" 
    
    # verify that business tag has been added ############################
    get "#{article_path articles(:suede_boots)}/relationships/tags"

    assert_response :success
    #$stderr.puts "#{response.body}" 
    json = JSON.parse response.body, symbolize_names: true
    #$stderr.puts "business tag id: #{tags(:business).id}" 
    #$stderr.puts "article tags: #{JSON.pretty_generate json}"

    assert          json,               "no json response"
    refute          json[:errors],      'response is error'
    assert_kind_of  Array, json[:data],        "response is not articles"
    assert          json[:data].detect{|item| item[:id] == tags(:business).id.to_s and item[:type] == 'tags'}
  end

end
