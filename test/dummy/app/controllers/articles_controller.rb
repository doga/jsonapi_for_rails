class ArticlesController < ApplicationController
  #before_action :test

  def index
    render json: {data:[]}, content_type: 'application/vnd.api+json'
  end

  private
    def test
      $stderr.puts "---------------------" 
      $stderr.puts "before_action :test" 
      $stderr.puts "@jsonapi_record: #{@jsonapi_record}" 
      $stderr.puts "@jsonapi_relationship: #{@jsonapi_relationship}" 
      $stderr.puts "@jsonapi_sparse_fieldsets: #{@jsonapi_sparse_fieldsets}" 
      $stderr.puts "@jsonapi_include: #{@jsonapi_include}" 
      $stderr.puts "---------------------" 
    end
end
