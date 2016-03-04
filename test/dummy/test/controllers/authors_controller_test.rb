require 'test_helper'

class AuthorsControllerTest < ActionDispatch::IntegrationTest
  test "can  respond with errors on create author invalid payload" do

    #$stderr.puts "#{ApplicationController::JSONAPI[:content_type]}" 

    post(
        authors_path,
        headers: {
        # 'Accept':       ApplicationController::JSONAPI[:content_type],
        # 'Content-Type': ApplicationController::JSONAPI[:content_type]
        },
        xhr: true,
        params: {
          type: :authors,
          data: {
            attributes: {
              name: 'nicholas'

            }
          }
        }
      )
   
    assert_response :success
    
    json = JSON.parse response.body, symbolize_names: true
    
    #$stderr.puts "#{json}" 
    assert          json,               "no json response"
    assert          json[:errors],      'response is error instead of record'
    assert          json[:errors][0][:detail]
    assert_equal    'data/attributes/email', json[:errors][0][:source][:pointer]
    
    refute          json[:data],        "response is not a record"

  end


  test "can update author with invalid attriubtes" do

    # create tag
    post(
      authors_path,
      xhr: true,
      params: {
        type: :authors,
        data: {
          attributes: {
            name: 'Nicholas',
            email: 'stockn@gmail.com'
          }
        }
      }
    )
    json = JSON.parse response.body, symbolize_names: true
    
    #$stderr.puts "#{json}" 

    # update tag
    patch "/api/v1/authors/" + json[:data][:id], params: {
      data: {
        type: json[:data][:type],
        id: json[:data][:id],
        attributes: {email: ''}
      }
    }
    json2 = JSON.parse response.body, symbolize_names: true
    #$stderr.puts "#{json2}" 
    
    assert          json2,               "no json2 response"
    assert          json2[:errors],      'response is error'
		assert          json2[:errors][0][:detail]
    assert_equal    'data/attributes/email', json2[:errors][0][:source][:pointer]
        

  end
end
