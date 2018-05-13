

class UsersController < ApplicationController
  get '/signup' do
    if logged_in?
      redirect "/gastro"
    else
      erb :"users/create_user"
    end
  end

  post '/signup' do
    if !params[:username].empty? && !params[:email].empty? && !params[:password].empty?
      @user = User.create(params)
      session[:user_id] = @user.id
      flash[:message] = "You're golden!"
      redirect "/gastro"
    else
      redirect "/signup"
    end
  end

  get '/login' do
    if logged_in?
      redirect "/gastro"
    else
      erb :"users/login"
    end
  end

  get '/logout' do
    if logged_in?
      session.clear
      redirect "/"
    else
      redirect "/"
    end
  end

  post '/login' do
    @user = User.find_by(name: params[:username])
    if !@user.nil? && @user.authenticate(params[:password])

      session[:user_id] = @user.id
      redirect "/gastro"
    else
      # also needs flash message - no user found!
      redirect "/login"
    end
  end

  # get '/:user_slug' do
  #   @user = User.find_by_slug(params[:user_slug])
  #   erb :"/users/show"
  # end
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
