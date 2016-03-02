# Require gem modules and classes
$LOAD_PATH.push File.expand_path('../lib', __FILE__)
# Maintain your gem's version
require 'jsonapi_for_rails/version'

# Gem description, including dependencies
Gem::Specification.new do |s|

  # Metadata #############################################################
  s.name        = 'jsonapi_for_rails'
  s.version     = JsonapiForRails::VERSION
  s.authors     = ['Doga Armangil']
  s.email       = ['doga.armangil@alumni.epfl.ch']
  s.homepage    = 'https://github.com/doga/jsonapi_for_rails'
  s.summary     = [
    'Jsonapi for Rails empowers your JSON API compliant APIs.',
    'Requires very little coding.',
    'http://jsonapi.org/format/'
  ].join(' ')
  # s.description = '' # this field is not used by rubygems.org?

  # SPDX IDs of chosen licenses (see http://spdx.org/licenses/)
  s.licenses     = Dir['*-LICENSE*'].map{|filename| filename.split('-').first}

  if s.respond_to? :metadata=
    s.metadata = {
      # List of RubyGems.org metadata that can be set manually on the gem webpage.
      # - Source Code URL
      'code' => 'https://github.com/doga/jsonapi_for_rails',
      # - Documentation URL
      'docs' => 'https://github.com/doga/jsonapi_for_rails#jsonapiforrails',
      # - Wiki URL
      'wiki' => '',
      # - Mailing List URL
      'mail' => '',
      # - Bug Tracker URL
      'bugs' => 'https://github.com/doga/jsonapi_for_rails/issues'
    }
  end

  s.has_rdoc = false # 
  s.extra_rdoc_files = []
  #s.rdoc_options << '--title' << 'Jsonapi for Rails'


  # Implementation #######################################################
  s.files = Dir[
    'lib/**/*', 
    'Rakefile', 
    'README*', '*-LICENSE*',
    'certs/*.pem'
  ]
  # s.require_paths = ['lib'] # 'lib' is the default
  bindir = 'bin'
  s.bindir = bindir # 'bin' is the default binary directory
  Dir.entries(bindir).reject{|dir| ['.', '..'].include? dir}.each do |binary|
    next if [
      # ignored binaries
      'test'
    ].include? binary
    s.executables << binary
  end

  # s.platform = Gem::Platform::RUBY # Gem::Platform::RUBY is the default, indicates a pure-Ruby gem.
  s.required_ruby_version =               '>= 2.0'
  s.add_runtime_dependency     'rails',   '>= 4.0.0', '< 5.1'
  s.add_development_dependency 'sqlite3', '>= 1.3'


  # Sign the gem #########################################################
  s.cert_chain = ['certs/doga.pem'] # 'doga' is my RubyGems.org handle
  s.signing_key = File.expand_path("~/.ssh/gem-private_key.pem") if $0 =~ /gem\z/
end
