class ArticlesController < ApplicationController
  #before_action :log_request
  #after_action  :log_response

=begin
  def index
    render json: {data:[]}, content_type: 'application/vnd.api+json'
  end
=end

  private
    def log_request
      return unless true or (
        request.fullpath.index('/relationships/tags') and 
        request.request_method == 'PATCH'
      )

      $stderr.puts "/> > > > > > > > > > > > > > > > > > > > > >" 
      #$stderr.puts "before_action :test" 

      # print HTTP request
      $stderr.puts "#{request.request_method} #{request.fullpath}" 
      %w[
        Accept Content-Type Content-Length Location
      ].each do |header|
        #$stderr.print "#{request.headers[header].class}" 
        next unless request.headers[header]
        $stderr.puts "#{header}: #{request.headers[header]}" 
      end

      #print rails instance variables
      $stderr.puts "--" 
      $stderr.puts "params: #{params.inspect}" 

      # print jsonapi instance variables
      if false
        $stderr.puts "--" 
        $stderr.puts "@jsonapi_record:           #{@jsonapi_record}" 
        $stderr.puts "@jsonapi_relationship:     #{@jsonapi_relationship}" 
        $stderr.puts "@jsonapi_sparse_fieldsets: #{@jsonapi_sparse_fieldsets}" 
        $stderr.puts "@jsonapi_include:          #{@jsonapi_include}" 
      end
      $stderr.puts "> > > > > > > > >" 
    end

    def log_response
      return unless true or (
        request.fullpath.index('/relationships/tags') and 
        request.request_method == 'PATCH'
      )

      $stderr.puts "< < < < < < < < <" 
      $stderr.puts "#{response.status}" 
      %w[
        Content-Type Content-Length
      ].each do |header|
        #$stderr.print "#{request.headers[header].class}" 
        next unless response.headers[header]
        $stderr.puts "#{header}: #{response.headers[header]}" 
      end
      if response.headers['Content-Type']
        $stderr.puts "--" 
        $stderr.puts "#{response.body}" 
      end
      $stderr.puts "\\< < < < < < < < < < < < < < < < < < < < < <" 
    end
end
