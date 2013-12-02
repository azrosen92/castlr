require 'rubygems'
require 'bundler'
Bundler.setup

require 'sinatra'
require 'sinatra/static_assets'

require './castlr'

run Sinatra::Application
