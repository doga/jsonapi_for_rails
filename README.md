# JsonapiForRails
A [Rails](http://rubyonrails.org/) 4+ plugin for providing [JSONAPI v1.0](http://jsonapi.org/format/1.0/) compliant APIs from your application with very little coding.

* [Installation](#installation)
* [Usage](#usage)
  1. [Set up one API controller per model](#1-set-up-one-api-controller-per-model)
  2. [Configure your API controller routes](#2-configure-your-api-controller-routes)
  3. [Verify your setup](#3-verify-your-setup)
* [Modifying the default API behaviour](#modifying-the-default-api-behaviour)
  * [Client authentication](#client-authentication)
  * [Access control](#access-control)
  * [Overriding an API end-point](#overriding-an-api-end-point)
* [Implementation status](#implementation-status)
* [Contributing](#contributing)
* [License](#license)

## Installation

```bash
$ # Optional security step (do this once)
$ gem cert --add <(curl -Ls https://raw.githubusercontent.com/doga/jsonapi_for_rails/master/certs/doga.pem)
$
$ # Go to the root directory of your existing Rails application
$ cd path/to/railsapp
$
$ # Update the gem file
$ cat >> Gemfile
gem 'jsonapi_for_rails'
$
$ # Install
$ # Optional security paramater: --trust-policy MediumSecurity
$ bundle install --trust-policy MediumSecurity
$
$ # Check the used version
$ bin/rails console
irb(main):001:0> JsonapiForRails::VERSION
=> "0.1.4"
irb(main):002:0> exit
$
```

## Usage

### 1. Set up one API controller per model

Generate a controller for each model that will be accessible from your API. Controller names need to be the plural version of your model names.

```bash
$ cd path/to/railsapp
$
$ # Generate your models
$ bin/rails generate model article
$ bin/rails generate model author
$
$ # Generate your API controllers
$ bin/rails generate controller articles
$ bin/rails generate controller authors
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
# app/controllers/articles_controller.rb

# Change the API controller's parent class
class ArticlesController < JsonapiResourcesController
  # ...
end

# Do the same with AuthorsController
```

### 2. Configure your API controller routes
Update your application routes as follows:

```ruby
# config/routes.rb
Rails.application.routes.draw do
  # ...

  scope '/api/v1' do # Optional scoping

    [ # List your API controllers here
      :articles, :authors
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
{"data":[{"type":"articles","id":"618037523"},{"type":"articles","id":"184578894"},{"type":"articles","id":"388548390"},{"type":"articles","id":"994552601"}]}
$
$ # Get an article
$ curl 'http://localhost:3000/api/v1/articles/618037523'
{"data":{"type":"articles","id":"618037523","attributes":{"title":"UK bank pay and bonuses in the spotlight as results season starts","content":"The pay deals handed to the bosses of Britain’s biggest banks will be in focus this week ...","created_at":"2016-02-26T16:18:39.265Z","updated_at":"2016-02-26T16:18:39.265Z"},"relationships":{"author":{"data":{"type":"authors","id":"1023487079"}}}}}
$
$ # Get only the title and author of an article, include the author's name
$ curl 'http://localhost:3000/api/v1/articles/618037523?filter%5Barticles%5D=title,author;include=author;filter%5Bauthors%5D=name'
{"data":{"type":"articles","id":"618037523","attributes":{"title":"UK bank pay and bonuses in the spotlight as results season starts"},"relationships":{"author":{"data":{"type":"authors","id":"1023487079"}}}},"include":[{"data":{"type":"authors","id":"1023487079","attributes":{"name":"Jill ..."},"relationships":{}}}]}
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
Access control for authenticated and unauthenticated clients can be implemented in `before_action` methods in your API controllers.

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
The `bin/rails routes` shell command shows you the end-points that *jsonapi_for_rails* defines. In order to change the behaviour of an action, you can define an action with the same name inside an API controller. *jsonapi_for_rails* provides utility methods and instance variables that can help you.

```ruby
# app/controllers/articles_controller.rb
class ArticlesController < JsonapiResourcesController 

  def index
    # These model-related utility methods are available inside all action methods.
    jsonapi_model_class      # =>  Article
    jsonapi_model_type       # => :articles

    # ...
  end

  def show
    # @jsonapi_record contains the current database record.
    # It is available inside all action methods (including all relationship
    # methods) except :index and :create.
    @jsonapi_record.to_jsonapi_hash # => {data: {...}}

    # ...
  end

  def relationship_show
    # @jsonapi_relationship is available in all relationship action methods.
    # @jsonapi_relationship[:definition] describes the current relationship.
    @jsonapi_relationship # => {:definition=>{:name=>:author, :type=>:to_one, :receiver=>{:type=>:authors, :class=>Author}}}

    # ...
  end

  def relationship_update
    # @jsonapi_relationship[:params] contains the parsed request body.
    # It is available for all relationship action methods except relationship_show.
    # @jsonapi_relationship[:params][:data] behaves like a Hash for relationships
    # of type :to_one, and as an Array for relationships of type :to_many.
    @jsonapi_relationship # => {:definition=>{...}, :params=>{"data"=>{"type"=>"authors", "id"=>"234455384"}}}

    # ...
  end

end
```

## Implementation status
The internal architecture is sound. Test coverage is currently being bulked up using *Rails 5 beta 2* (but the plugin should be compatible with *Rails 4+*). And missing features are being added. The intention is to release a 1.0 version around mid-2016.

Feature support roundup:

* [Inclusion of related resources](http://jsonapi.org/format/1.0/#fetching-includes) is currently only implemented for requests that return a single resource, and relationship paths are not supported. 
* [Sparse fieldsets](http://jsonapi.org/format/1.0/#fetching-sparse-fieldsets) is currently only implemented for requests that return a single resource. 
* [Sorting](http://jsonapi.org/format/1.0/#fetching-sorting) is currently not implemented.
* [Pagination](http://jsonapi.org/format/1.0/#fetching-pagination) is currently not implemented.
* [Deleting resources](http://jsonapi.org/format/1.0/#crud-deleting) is currently not implemented.

## Contributing
Feel free to share your experience using this software. If you find a bug in this project, have trouble following the documentation or have a question about the project – create an [issue](https://github.com/doga/jsonapi_for_rails/issues).

## License
The gem is available as open source under the terms of the [MIT License](http://opensource.org/licenses/MIT).
