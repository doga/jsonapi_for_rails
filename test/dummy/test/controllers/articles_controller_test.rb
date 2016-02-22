require 'test_helper'

class ArticlesControllerTest < ActionDispatch::IntegrationTest
  test "get list of articles" do
    assert_no_difference 'Article.count' do
      get articles_path
    end

    assert_response :success
    json = JSON.parse response.body, symbolize_names: true
    #$stderr.puts "#{json}" 
    assert          json,               "no json response"
    refute          json[:errors],      'response is error'
    assert_kind_of  Array, json[:data],        "response is not articles"
    json[:data].each do |data|
      assert_equal 0, data.reject{|k,v| [:type, :id].include? k }.size, "attribute is other than :type, :id"
      assert_equal 'articles', data[:type], "resource is not articles"
    end

  end

  test "get article"  do
    get article_path(articles(:uk_bank_and_bonuses)), {
      params: {
        include:              'author,tags',
        'fields[articles]' => 'title,author,tags',
        'fields[authors]'  => 'name,email'
      },
      headers: {},
      xhr: true
    }
    assert_response :success
    json = JSON.parse response.body, symbolize_names: true
    $stderr.puts "#{json}" 
    
    assert json
    assert json[:data]
    assert_kind_of String, json[:data][:type]
    assert_kind_of Fixnum, json[:data][:id]
    assert_kind_of Hash, json[:data][:attributes]
    assert_kind_of Hash, json[:data][:relationships]
  end

  test "get related author" do
    get "#{article_path articles(:uk_bank_and_bonuses)}/relationships/author"

    assert_response :success
    json = JSON.parse response.body, symbolize_names: true
    #$stderr.puts "#{json}" 
    assert_equal 'authors', json[:data][:type], "bad type"
    author = Author.find(json[:data][:id])
    assert author
    #$stderr.puts "#{author.inspect}" 
  end

  test "set related author" do
    patch(
      "#{article_path articles(:suede_boots)}/relationships/author",
      xhr: true,
      params: {
        data: {
          type: authors(:press_association)[:type],
          id:   authors(:press_association)[:id]
        }
      }
    )

    assert_response :success
    json = JSON.parse response.body, symbolize_names: true
    #$stderr.puts "#{json}" 
    
  end

  test "get related tags" do
    get "#{article_path articles(:uk_bank_and_bonuses)}/relationships/tags"

    assert_response :success
    json = JSON.parse response.body, symbolize_names: true
    #$stderr.puts "#{json}" 

    assert          json,               "no json response"
    refute          json[:errors],      'response is error'
    assert_kind_of  Array, json[:data],        "response is not articles"
    json[:data].each do |data|
      assert_equal 0, data.reject{|k,v| [:type, :id].include? k }.size, "attribute is other than :type, :id"
      assert_equal 'tags', data[:type], "resource is not tags"
    end
  end

  test "add related tag" do
    patch(
      "#{article_path articles(:suede_boots)}/relationships/tags",
      xhr: true,
      params: {
        data: [
          {
            type: tags(:business)[:type],
            id: tags(:business)[:id]
          }
        ]
      }
    )

    assert_response :success
    json = JSON.parse response.body, symbolize_names: true
    #$stderr.puts "#{json}" 
    
  end
end
