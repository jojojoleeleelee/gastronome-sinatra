
class RecipesController < ApplicationController
  get "/gastro" do
    @user = current_user
    if logged_in?
      erb :"/recipes/recipes"
    else
      redirect "/login"
    end
  end

  get '/gastro/new' do
    if logged_in?
      erb :"/gastro/create_recipe"
    else
      redirect "/login"
    end
  end

  post '/gastro' do
    if !params[:name].empty? && !scrape_recipes(params[:name]).empty?
      @recipe = Recipe.create(name: params[:name].downcase)
      @recipe.content = params[:content]
      @recipe.user_id = session[:user_id]
      @recipe.verse = scrape_recipes(params[:name]).join(" *** ")
      @recipe.save
      flash[:message] = "I feel ya mate."
      redirect "/gastro/#{@recipe.slug}"
    else
      flash[:message] = "Sorry, I can't understand!"
      redirect '/gastro/new'
    end
  end

end
