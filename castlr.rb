require 'sinatra'
require 'sinatra/json'
require 'titleize'

require './castle_finder_tools'

#class Castlr < Sinatra::Base  

  get '/' do
    @countries = get_all_castles
    erb :index
  end

  get '/map' do
    @country = params[:castle]
    erb :map
  end

  get '/map/:country' do |country|
    country_hash = get_all_castles
    puts country_hash
    castles = get_all_castles_from country_hash[country]
    @data = {}
    castles.each do |country, url| 
      @data[country.titleize] = get_data_about url 
    end
    #return @data as json
    json :info => @data
  end
#end
