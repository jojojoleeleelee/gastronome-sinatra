things to incorporate:
class User
username
email
password
<!-- timestamp?? -->

class Recipe
name
ingredients
time
picture
url
flavor profile
dish-type (appetizer, main, dessert, soup)

class Flavor
sweet
sour
salty
bitter
umami (savory)

also, a class for scraping recipes
scrape content which includes:
ingredients
time
author???
url
photo if available

class for converting the recipe to customized version
this will use the flavor profile ingredient that the user puts in

another class to scrape flavor profile matches??
what I mean by this is - basically, if the person wants sweet,
the list of suggested ingredients will likely be sweet ingredients.
So if they want steak, they can get steak with roasted cherry tomato brine or something that complements this want of sweet notes in their dish.

so I need a class for converting wanted flavor to ingredients
this would then edit the scraped recipe by the collected results.
Or wait, should it just be suggestions?

For now, keep it simple. Or as simple as you can.

Users has_many: :recipes
user.recipes ("Brownies", "Pork chops", "Chia pudding")
has_many: :flavor
user.flavors ("sweet", "savory") - this would indicate the user really likes sweet and savory as opposed to the other flavor profiles. Perhaps keep a count of how many instances of sweet/savory/etc etc the user wanted?

Ingredient belongs_to: :flavor
ingredient.flavor = sweet (primarily speaking, of course)
belongs_to :user
ingredient.user (jojo lee)
ingredient has_many: :recipes
choco = Ingredient.new("chocolate")
choco.recipes = ["Brownies", "Chocolate Pudding", "Chocolate Babka"]

Flavor
has_many: :recipes
has_many: :ingredients
has_many: :users

On a side note, should flavors really be a separate class?? Is this really necessary? Maybe not in the database, but as a class in the concerns folder of the lib directory.

websites to scrape
https://www.epicurious.com/
https://www.bonappetit.com/
https://food52.com/
https://www.thekitchn.com/
