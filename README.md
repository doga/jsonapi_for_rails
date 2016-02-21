# JsonapiForRails
A [Rails](http://rubyonrails.org/) 5+ plugin for providing a [JSONAPI v1.0](http://jsonapi.org/format/1.0/) API from your application with very little coding.

## Usage

### Controllers

First, generate a controller for each model that will be accessible from your API. Controller names need to be the plural version of your model names.

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

Next, enable JSONAPI in a parent class of your API controllers. 

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

  # Enable JSONAPI
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
```

```ruby
# app/controllers/articles_controller.rb

# Change the API controller's parent class
class ArticlesController < JsonapiResourcesController
  # ...
end
```

### Routes
Generate your API routes:

```ruby
# config/routes.rb

Rails.application.routes.draw do
  # ...

  # JSONAPI routes
  scope '/api/v1' do # Optional scoping

    [ # List of your API controllers
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

### Client permissions
By default, all API end-points are accessible to all clients. Client authentication and read/write permissions are left as an exercice to the developer.

Provided [renderers](lib/jsonapi_for_rails/controller/utils/render.rb) can be used to implement `before_action` controller methods if needed.

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
