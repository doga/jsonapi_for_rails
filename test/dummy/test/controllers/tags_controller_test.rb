require 'test_helper'

class TagsControllerTest < ActionDispatch::IntegrationTest
  test "can create tag" do

    #$stderr.puts "#{ApplicationController::JSONAPI[:content_type]}" 

    assert_difference 'Tag.count' do
      post(
        tags_path,
        headers: {
        # 'Accept':       ApplicationController::JSONAPI[:content_type],
        # 'Content-Type': ApplicationController::JSONAPI[:content_type]
        },
        xhr: true,
        params: {
          type: :tags,
          data: {
            attributes: {
              name: 'Travel'
            }
          }
        }
      )
    end
    assert_response :success
    json = JSON.parse response.body, symbolize_names: true
    #$stderr.puts "#{json}" 
    assert          json,               "no json response"
    refute          json[:errors],      'response is error instead of record'
    assert          json[:data],        "response is not a record"

  end

  test "can update tag" do

    # create tag
    post(
      tags_path,
      xhr: true,
      params: {
        type: :tags,
        data: {
          attributes: {
            name: 'Fun'
          }
        }
      }
    )
    json = JSON.parse response.body, symbolize_names: true
    #$stderr.puts "#{json}" 

    # update tag
    patch tag_path(json[:data][:id]), params: {
      data: {
        type: json[:data][:type],
        id: json[:data][:id],
        attributes: {name: 'Leisure'}
      }
    }
    json2 = JSON.parse response.body, symbolize_names: true
    #$stderr.puts "#{json2}" 
    assert          json2,               "no json2 response"
    refute          json2[:errors],      'response is error'
    assert_kind_of  Hash, json2[:data],        "response is not hash" 
    assert_equal json[:data][:id], json2[:data][:id], "update has changed the id"
    assert_equal 'Leisure', json2[:data][:attributes][:name], "attribute has not been updated"

  end

end
