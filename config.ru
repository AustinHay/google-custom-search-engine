require './advanced-search'
run Sinatra::Application

require 'sass/plugin/rack'
use Sass::Plugin::Rack

