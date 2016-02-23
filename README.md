# JsonapiForRails
A [Rails](http://rubyonrails.org/) 5+ plugin for providing a [JSONAPI v1.0](http://jsonapi.org/format/1.0/) API from your application with very little coding.

## Usage

### 1. Set up one API controller per model

Generate a controller for each model that will be accessible from your API. Controller names need to be the plural version of your model names.

```bash
$ # Go to the root directory of your existing Rails application
$ cd path/to/railsapp
$
$ # Generate your models
$ bin/rails generate model author
$ bin/rails generate model article
$
$ # Generate your API controllers
$ bin/rails generate controller authors
$ bin/rails generate controller articles
```

Then enable JSONAPI in a parent class of your API controllers. 

```ruby
# app/controllers/application_controller.rb
class ApplicationController < ActionController::Base # or ActionController::API

  # Enable JSONAPI
  acts_as_jsonapi_resources

  # ...
end
```

If only some of your controllers are JSONAPI controllers, then create a parent controller for only those controllers, and enable JSONAPI inside that controller rather than `ApplicationController`. 

```bash
$ cat > app/controllers/jsonapi_resources_controller.rb

class JsonapiResourcesController < ApplicationController
  acts_as_jsonapi_resources

  # ...
end
```

```ruby
# app/controllers/authors_controller.rb

# Change the API controller's parent class
class AuthorsController < JsonapiResourcesController
  # ...
end

# Do the same with ArticlesController
```

### 2. Configure your API controller routes
Update your application routes as follows:

```ruby
# config/routes.rb
Rails.application.routes.draw do
  # ...

  scope '/api/v1' do # Optional scoping

    [ # List your API controllers here
      :authors, :articles
    ].each do |resources_name|
      resources resources_name do
        controller resources_name do
          get     'relationships/:relationship', action: "relationship_show"
          patch   'relationships/:relationship', action: "relationship_update"
          post    'relationships/:relationship', action: "relationship_add"
          delete  'relationships/:relationship', action: "relationship_remove"
        end
      end
    end

  end

  # ...
end

```

### 3. Verify your setup
After populating your database and launching the built-in Rails server with the `bin/rails server` shell command, you can issue some HTTP requests to your API and verify the correctness of the responses.

```bash
$ # Get the list of articles
$ curl 'http://localhost:3000/api/v1/articles'
{"data":[{"type":"articles","id":184578894},{"type":"articles","id":388548390},{"type":"articles","id":618037523},{"type":"articles","id":994552601}]}
$
$ # Get an article
$ curl 'http://localhost:3000/api/v1/articles/184578894'
{"data":{"type":"articles","id":618037523,"attributes":{"title":"UK bank pay and bonuses in the spotlight as results season starts","content":"The pay deals handed to the bosses of Britain’s biggest banks will be in focus ...","created_at":"2016-02-22T16:57:43.401Z","updated_at":"2016-02-22T16:57:43.401Z"},"relationships":{"author":{"data":{"type":"authors","id":1023487079}}}}}
$
$ # Get only the title of an article, include the author name
$ curl 'http://localhost:3000/api/v1/articles/184578894?filter%5Barticles%5D=title,author;include=author;filter%5Bauthors%5D=name'
{"data":{"type":"articles","id":618037523,"attributes":{"title":"UK bank pay and bonuses in the spotlight as results season starts"},"relationships":{"author":{"data":{"type":"authors","id":1023487079}}}},"include":[{"data":{"type":"authors","id":1023487079,"attributes":{"name":"..."},"relationships":{}}}]}

```

## Modifying the default API behaviour
By default, all API end-points are accessible to all clients, and all end-points behave the same way for all clients. In a real-world setting, you may want to restrict access to an end-point and/or change the behaviour of an end-point depending on the client. 

### Client authentication
Clients can be authenticated with a `before_action` method in your API controller. Inside controllers, instance variable names starting with the `@jsonapi_` prefix and method names starting with the `jsonapi_` prefix are reserved by *jsonapi_for_rails*, so try to avoid those.

```ruby
# app/controllers/jsonapi_resources_controller.rb
class JsonapiResourcesController < ApplicationController
  acts_as_jsonapi_resources

  before_action :authenticate

private
  def authenticate
    # ...
  end
end
```

### Access control
Access control for authenticated and unauthenticated users can be implemented inside a `before_action` method in your API controllers.

```ruby
# app/controllers/jsonapi_resources_controller.rb
class JsonapiResourcesController < ApplicationController
  acts_as_jsonapi_resources

  before_action :permit_read, only: [
    :index,
    :show,
    :relationship_show
  ]

  before_action :permit_write, only: [
    :create, 
    :update, 
    :destroy,
    :relationship_update,
    :relationship_add,
    :relationship_remove
  ]

private
  def permit_read
    # ...
  end

  def permit_write
    # ...
  end
end
```

### Overriding an API end-point
The `bin/rails routes` command will show you the end-points that *jsonapi_for_rails* defines. In order to change the behaviour of an action, you can define an action with the same name inside an API controller. *jsonapi_for_rails* provides utility methods and instance variables that can help you.

```ruby
# app/controllers/articles_controller.rb
class ArticlesController < JsonapiResourcesController 

  def index
    jsonapi_model_class      # =>  Article
    jsonapi_model_class_name # => "Article"
    jsonapi_model_type       # => :articles

    # ...
  end

  def show
    @jsonapi_record.to_jsonapi_hash # => {data: {...}}

    # ...
  end

  def relationship_show
    @jsonapi_relationship # => {:definition=>{:name=>:author, :type=>:to_one, :receiver=>{:type=>:authors, :class=>Author}}

    # ...
  end

end
```

## Implementation status
* [Inclusion of related resources](http://jsonapi.org/format/1.0/#fetching-includes) is currently only implemented for resource requests that return a single resource. 
* [Sparse fieldsets](http://jsonapi.org/format/1.0/#fetching-sparse-fieldsets) is currently only implemented for resource requests that return a single resource. 
* [Sorting](http://jsonapi.org/format/1.0/#fetching-sorting) is currently unimplemented.
* [Pagination](http://jsonapi.org/format/1.0/#fetching-pagination) is currently unimplemented.
* [Deleting resources](http://jsonapi.org/format/1.0/#crud-deleting) is currently unimplemented.
* Test coverage is sparse.

## Installation

### Edge version

```bash
$ # Clone this git repository
$ git clone https://github.com/doga/jsonapi_for_rails.git
$
$ # Update your Rails application's gem file
$ cat >> path/to/railsapp/Gemfile

group :development do
  gem 'jsonapi_for_rails', path: 'path/to/jsonapi_for_rails'
end
```

This is suitable for experimenting, but not for production.

### Latest stable version

```bash
$ # Update your Rails application's gem file
$ cat >> path/to/railsapp/Gemfile

gem 'jsonapi_for_rails'
```

## Contributing
If you find a bug in this project, have trouble following the documentation or have a question about the project – create an [issue](https://guides.github.com/activities/contributing-to-open-source/#contributing).

## License
The gem is available as open source under the terms of the [MIT License](http://opensource.org/licenses/MIT).
