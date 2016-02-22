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
After populating your database and launching the built-in Rails server with the `bin/rails server` command, you can issue some HTTP requests to your API and verify the correctness of the responses.

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
By default, all API end-points are accessible to all clients.

Provided [renderers](lib/jsonapi_for_rails/controller/utils/render.rb) can be used to implement `before_action` controller methods if needed.

### Client authentication
TODO

### Client permissions
TODO

### Overriding an API end-point
TODO

## Implementation status
* [Inclusion of related resources](http://jsonapi.org/format/1.0/#fetching-includes) is currently only implemented for resource requests that return a single resource. 
* [Sparse fieldsets](http://jsonapi.org/format/1.0/#fetching-sparse-fieldsets) is currently only implemented for resource requests that return a single resource. 
* [Sorting](http://jsonapi.org/format/1.0/#fetching-sorting) is currently unimplemented.
* [Pagination](http://jsonapi.org/format/1.0/#fetching-pagination) is currently unimplemented.
* [Deleting resources](http://jsonapi.org/format/1.0/#crud-deleting) is currently unimplemented.
* Test coverage is sparse.

## Installation
Add this line to your application's Gemfile:

```ruby
gem 'jsonapi_for_rails'
```

And then execute:
```bash
$ bundle
```

Or install it yourself as:
```bash
$ gem install jsonapi_for_rails
```

## Contributing
Contribution directions go here.

## License
The gem is available as open source under the terms of the [MIT License](http://opensource.org/licenses/MIT).
