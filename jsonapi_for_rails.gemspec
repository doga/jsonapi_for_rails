$:.push File.expand_path("../lib", __FILE__)

# Maintain your gem's version:
require "jsonapi_for_rails/version"

# Describe your gem and declare its dependencies:
Gem::Specification.new do |s|
  s.name        = "jsonapi_for_rails"
  s.version     = JsonapiForRails::VERSION
  s.authors     = ["Doga Armangil"]
  s.email       = ["doga.armangil@alumni.epfl.ch"]
  s.homepage    = "http://jsonapi.org/format/"
  s.summary     = "JSONAPI plugin for Rails"
  s.description = "Use this for providing a JSONAPI API with your controllers and models."
  s.license     = "MIT"

  s.files = Dir["{app,config,db,lib}/**/*", "MIT-LICENSE", "Rakefile", "README.md"]

  s.add_dependency "rails", ">= 5.0.0.beta2", "< 5.1"

  s.add_development_dependency "sqlite3"
end
