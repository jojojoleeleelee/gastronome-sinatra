require 'spec_helper'

describe ApplicationController do

  describe "Homepage" do
    it 'loads the homepage' do
      get '/'
      expect(last_response.status).to eq(200)
      expect(last_response.body).to include("Gastronome")
    end
  end

  describe "Signup Page" do

    it 'loads the signup page' do
      get '/signup'
      expect(last_response.status).to eq(200)
    end

    it 'signup directs user to Gastronome index' do
      params = {
        username: "Dan",
        email: "dan@gmail.com",
        password: "Godisgood"
      }
      post '/signup', params
      expect(last_response.location).to include("/recipe")
    end
    it 'does not let a user sign up without a username' do
         params = {
           :username => "",
           :email => "skittles@aol.com",
           :password => "rainbows"
         }
         post '/signup', params
         expect(last_response.location).to include('/signup')
       end

     it 'does not let a user sign up without an email' do
       params = {
         :username => "skittles123",
         :email => "",
         :password => "rainbows"
       }
       post '/signup', params
       expect(last_response.location).to include('/signup')
     end

     it 'does not let a user sign up without a password' do
       params = {
         :username => "skittles123",
         :email => "skittles@aol.com",
         :password => ""
       }
       post '/signup', params
       expect(last_response.location).to include('/signup')
     end

     it 'does not let a logged in user view the signup page' do
       user = User.create(:username => "skittles123", :email => "skittles@aol.com", :password => "rainbows")
       params = {
         :username => "skittles123",
         :email => "skittles@aol.com",
         :password => "rainbows"
       }
       post '/signup', params
       session = {}
       session[:user_id] = user.id
       get '/signup'
       expect(last_response.location).to include('/recipe')
     end
  end

  describe "login" do
   it 'loads the login page' do
     get '/login'
     expect(last_response.status).to eq(200)
   end

   it 'loads the recipe index after login' do
     user = User.create(:username => "becky567", :email => "starz@aol.com", :password => "kittens")
     params = {
       :username => "becky567",
       :password => "kittens"
     }
     post '/login', params
     expect(last_response.status).to eq(302)
     follow_redirect!
     expect(last_response.status).to eq(200)
     expect(last_response.body).to include("Welcome,")
   end

   it 'does not let user view login page if already logged in' do
     user = User.create(:username => "becky567", :email => "starz@aol.com", :password => "kittens")

     params = {
       :username => "becky567",
       :password => "kittens"
     }
     post '/login', params
     session = {}
     session[:user_id] = user.id
     get '/login'
     expect(last_response.location).to include("/recipe")
   end
 end

 describe "logout" do
   it "lets a user logout if they are already logged in" do
     user = User.create(:username => "becky567", :email => "starz@aol.com", :password => "kittens")

     params = {
       :username => "becky567",
       :password => "kittens"
     }
     post '/login', params
     get '/logout'
     expect(last_response.location).to include("/login")
   end

   it 'does not let a user logout if not logged in' do
     get '/logout'
     expect(last_response.location).to include("/")
   end

   it 'does not load /recipe if user not logged in' do
     get '/recipe'
     expect(last_response.location).to include("/login")
   end

   it 'does load /recipe if user is logged in' do
     user = User.create(:username => "becky567", :email => "starz@aol.com", :password => "kittens")

     visit '/login'

     fill_in(:username, :with => "becky567")
     fill_in(:password, :with => "kittens")
     click_button 'submit'
     expect(page.current_path).to eq('/recipe')
   end
 end


 describe 'index action' do
   context 'logged in' do
     it 'lets a user view the recipes index if logged in' do
       user1 = User.create(:username => "becky567", :email => "starz@aol.com", :password => "kittens")
       recipe1 = Recipe.create(:content => "chocolate", :user_id => user1.id)

       user2 = User.create(:username => "silverstallion", :email => "silver@aol.com", :password => "horses")
       recipe2 = Recipe.create(:content => "Beet Salad", :user_id => user2.id)

       visit '/login'

       fill_in(:username, :with => "becky567")
       fill_in(:password, :with => "kittens")
       click_button 'submit'
       visit "/recipe"

       expect(page.body).to include(recipe1.content)
       expect(page.body).to include(recipe2.content)
     end
   end

   context 'logged out' do
     it 'does not let a user view the recipe index if not logged in' do
       get '/recipe'
       expect(last_response.location).to include("/login")
     end
   end
 end

 describe 'new action' do
   context 'logged in' do
     it 'lets user view new recipe form if logged in' do
       user = User.create(:username => "becky567", :email => "starz@aol.com", :password => "kittens")

       visit '/login'

       fill_in(:username, :with => "becky567")
       fill_in(:password, :with => "kittens")
       click_button 'submit'
       visit '/recipe/new'
       expect(page.status_code).to eq(200)
     end

     it 'lets user create a recipe if they are logged in' do
       user = User.create(:username => "becky567", :email => "starz@aol.com", :password => "kittens")

       visit '/login'

       fill_in(:username, :with => "becky567")
       fill_in(:password, :with => "kittens")
       click_button 'submit'

       visit '/recipe/new'
       fill_in(:content, :with => "Pumpkin pie")
       click_button 'submit'

       user = User.find_by(:username => "becky567")
       recipe = Recipe.find_by(:content => "Pumpkin pie")
       expect(recipe).to be_instance_of(Recipe)
       expect(recipe.user_id).to eq(user.id)
       expect(page.status_code).to eq(200)
     end

     it 'does not let a user create recipes from another user' do
       user = User.create(:username => "becky567", :email => "starz@aol.com", :password => "kittens")
       user2 = User.create(:username => "silverstallion", :email => "silver@aol.com", :password => "horses")

       visit '/login'

       fill_in(:username, :with => "becky567")
       fill_in(:password, :with => "kittens")
       click_button 'submit'

       visit '/recipe/new'

       fill_in(:content, :with => "Noodles")
       click_button 'submit'

       user = User.find_by(:id=> user.id)
       user2 = User.find_by(:id => user2.id)
       recipe = Recipe.find_by(:content => "Noodles")
       expect(recipe).to be_instance_of(Recipe)
       expect(recipe.user_id).to eq(user.id)
       expect(recipe.user_id).not_to eq(user2.id)
     end

     it 'does not let a user create a blank recipe' do
       user = User.create(:username => "becky567", :email => "starz@aol.com", :password => "kittens")

       visit '/login'

       fill_in(:username, :with => "becky567")
       fill_in(:password, :with => "kittens")
       click_button 'submit'

       visit '/recipe/new'

       fill_in(:content, :with => "")
       click_button 'submit'

       expect(Recipe.find_by(:content => "")).to eq(nil)
       expect(page.current_path).to eq("/recipe/new")
     end
   end

   context 'logged out' do
     it 'does not let user view new recipe form if not logged in' do
       get '/recipe/new'
       expect(last_response.location).to include("/login")
     end
   end
 end

 describe 'show action' do
   context 'logged in' do
     it 'displays a single recipe' do

       user = User.create(:username => "becky567", :email => "starz@aol.com", :password => "kittens")
       recipe = Recipe.create(:content => "Chocolate Chip Cookies", :user_id => user.id)

       visit '/login'

       fill_in(:username, :with => "becky567")
       fill_in(:password, :with => "kittens")
       click_button 'submit'

       visit "/recipe/#{recipe.id}"
       expect(page.status_code).to eq(200)
       expect(page.body).to include("Delete Recipe")
       expect(page.body).to include(recipe.content)
       expect(page.body).to include("Edit Recipe")
     end
   end

   context 'logged out' do
     it 'does not let a user view a recipe' do
       user = User.create(:username => "becky567", :email => "starz@aol.com", :password => "kittens")
       recipe = Recipe.create(:content => "Quinoa Rice", :user_id => user.id)
       get "/recipe/#{recipe.id}"
       expect(last_response.location).to include("/login")
     end
   end
 end

 describe 'edit action' do
   context "logged in" do
     it 'lets a user view recipe edit form if they are logged in' do
       user = User.create(:username => "becky567", :email => "starz@aol.com", :password => "kittens")
       recipe = Recipe.create(:content => "recipeing!", :user_id => user.id)
       visit '/login'

       fill_in(:username, :with => "becky567")
       fill_in(:password, :with => "kittens")
       click_button 'submit'
       visit '/recipe/1/edit'
       expect(page.status_code).to eq(200)
       expect(page.body).to include(recipe.content)
     end

     it 'does not let a user edit a recipe they did not create' do
       user1 = User.create(:username => "becky567", :email => "starz@aol.com", :password => "kittens")
       recipe1 = Recipe.create(:content => "Jello", :user_id => user1.id)

       user2 = User.create(:username => "silverstallion", :email => "silver@aol.com", :password => "horses")
       recipe2 = Recipe.create(:content => "Curry", :user_id => user2.id)

       visit '/login'
       fill_in(:username, :with => "becky567")
       fill_in(:password, :with => "kittens")
       click_button 'submit'
       session = {}
       session[:user_id] = user1.id
       visit "/recipe/#{recipe2.id}/edit"
       expect(page.current_path).to include('/recipe')
     end

     it 'lets a user edit their own recipe if they are logged in' do
       user = User.create(:username => "becky567", :email => "starz@aol.com", :password => "kittens")
       recipe = Recipe.create(:content => "Curry", :user_id => 1)
       visit '/login'

       fill_in(:username, :with => "becky567")
       fill_in(:password, :with => "kittens")
       click_button 'submit'
       visit '/recipe/1/edit'

       fill_in(:content, :with => "Green Curry")

       click_button 'submit'
       expect(Recipe.find_by(:content => "Green Curry")).to be_instance_of(Recipe)
       expect(Recipe.find_by(:content => "Curry")).to eq(nil)
       expect(page.status_code).to eq(200)
     end

     it 'does not let a user edit a text with blank content' do
       user = User.create(:username => "becky567", :email => "starz@aol.com", :password => "kittens")
       recipe = Recipe.create(:content => "Chocolate Brownies", :user_id => 1)
       visit '/login'

       fill_in(:username, :with => "becky567")
       fill_in(:password, :with => "kittens")
       click_button 'submit'
       visit '/recipe/1/edit'

       fill_in(:content, :with => "")

       click_button 'submit'
       expect(Recipe.find_by(:content => "Chocolate Brownies")).to be(nil)
       expect(page.current_path).to eq("/recipe/1/edit")
     end
   end

   context "logged out" do
     it 'does not load -- instead redirects to login' do
       get '/recipe/1/edit'
       expect(last_response.location).to include("/login")
     end
   end
 end

 describe 'delete action' do
   context "logged in" do
     it 'lets a user delete their own recipe if they are logged in' do
       user = User.create(:username => "becky567", :email => "starz@aol.com", :password => "kittens")
       recipe = Recipe.create(:content => "Chicken", :user_id => 1)
       visit '/login'

       fill_in(:username, :with => "becky567")
       fill_in(:password, :with => "kittens")
       click_button 'submit'
       visit 'recipe/1'
       click_button "Delete Recipe"
       expect(page.status_code).to eq(200)
       expect(Recipe.find_by(:content => "Chicken")).to eq(nil)
     end

     xit 'does not let a user delete a recipe they did not create' do
       user1 = User.create(:username => "becky567", :email => "starz@aol.com", :password => "kittens")
       recipe1 = Recipe.create(:content => "Kimbap", :user_id => user1.id)

       user2 = User.create(:username => "silverstallion", :email => "silver@aol.com", :password => "horses")
       recipe2 = Recipe.create(:content => "look at this recipe", :user_id => user2.id)

       visit '/login'

       fill_in(:username, :with => "becky567")
       fill_in(:password, :with => "kittens")
       click_button 'submit'
       visit "recipe/#{recipe2.id}"
       click_button "Delete Recipe"
       expect(page.status_code).to eq(200)
       expect(Recipe.find_by(:content => "look at this recipe")).to be_instance_of(Recipe)
       expect(page.current_path).to include('/recipe')
     end
   end

   context "logged out" do
     it 'does not load let user delete a recipe if not logged in' do
       recipe = Recipe.create(:content => "chilli", :user_id => 1)
       visit '/recipe/1'
       expect(page.current_path).to eq("/login")
     end
   end
 end


  describe 'RecipeScraper' do

    describe "#scrape_recipes" do
      it "can scrape recipes based on ingredients" do
        @ingredient = "chocolate"
        answer = 'Chocolate Beet Brownies'
        scraped_recipe = scrape_recipe(@ingredient)
        expect(scraped_recipe).to be_a(String)
        expect(scraped_verse).to include(answer)
      end
    end
  end
end
