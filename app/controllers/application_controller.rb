require './config/environment'
require 'sinatra/base'
require 'open-uri'
require 'nokogiri'
require 'rack-flash'

class ApplicationController < Sinatra::Base

  configure do
    set :public_folder, 'public'
    set :views, 'app/views'
    enable :sessions
    set :session_secret, "confidant_secret"
    use Rack::Flash
  end

  get "/" do
    erb :welcome
  end
  helpers do
    def logged_in?
      !!session[:user_id]
    end

    def current_user
      User.find(session[:user_id])
    end

    def users_emotion?
      current_user.id == session[:user_id]
    end

    def scrape_recipes(flavor)
      doc = Nokogiri::HTML(open(""))

      # @recipes = doc.css('div.bible-item-text').map do |v| v.text.gsub("\n",'').chomp("In Context | Full Chapter | Other Translations ")
      # end
      @recipes
    end
  end
end
