path = File.absolute_path('.')

require "#{path}/config/sprinkle/capistrano_variables"

deployment do
  # mechanism for deployment
  delivery :capistrano do
    begin
      recipes 'Capfile'
    rescue LoadError
      recipes 'deploy'
    end
  end

  source do
    prefix    '/usr/local'
    archives  '/usr/local/sources'
    builds    '/usr/local/builds'
  end
end

# Require Packages
require "#{path}/packages/essentials"
require "#{path}/packages/apache"
require "#{path}/packages/rbenv"
require "#{path}/packages/mysql"
require "#{path}/packages/passenger_standalone"
require "#{path}/packages/rails_development"
require "#{path}/packages/memcache"

# What we're installing to your server
# Take what you want, leave what you don't
# Build up your own and strip down your server until you get it right. 
policy :stack, :roles => :app do
  # requires :apt_update             # For first run

  requires :essentials               # Standard utilities, build-essentials, git, etc.
  requires :ruby_rbenv               # Install rbenv, ruby-build and ruby
  requires :webserver                # Apache or Nginx
  requires :appserver                # Passenger (standalone)
  requires :cache_server             # Local cache server, currently Memcache
  requires :web_development          # Web Development (Rails)
  requires :database                 # MySQL or Postgres, also installs rubygems for each
end
