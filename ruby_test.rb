# Instructions for this test:
# 1. Please clone this gist as a git repo locally
# 2. Create your own github repo called 'rubytest' (or a name of your choice)
#    and add this repo as a new remote to the cloned repo
# 3. Edit this file to answer the questions, and push this file with answers
#    back out to your own 'rubytest' repo.

# Problem 1. Explain briefly what this code does, fix any bugs, then clean it
# up however you like and write a unit test using RSpec.

####################################################################
# This function takes a collections (array or range) and returns a string
# representation in the format of an array. It's like a function for
# pretty-printing collections into array format. It could be used for
# serializing a collection of data and storing it in a file or a database.
####################################################################
def bracketed_list(values)
 temp = values.inject("["){|result, val| result + "#{val.to_s}, "}
 temp = temp.rstrip().chop()
 temp += "]"
end

describe "bracketed_list serializer" do
  it "should return the string representation of an array" do
    string_representation = bracketed_list [1,2,3,4,5,6,7,8,9,0]
    string_representation.should == "[1, 2, 3, 4, 5, 6, 7, 8, 9, 0]"
  end
end
# Problem 2. This is a piece of code found in a fictional Rails controller and model.
#
# Point out any bugs or security problems in the code, fix them, and refactor the code to
# make it cleaner. Hint: think 'fat model, skinny controller'. Explain in a few sentences
# what 'fat model, skinny controller' means.

####################################################################
# There is a security problem, because we are not escaping the
# :name and :user_id parameters. The values of these parameters
# will be used in a database query. Given that the parameters likely
# came from a user, we should escape them to prevent SQL injection attacks.
#
# Also, there was a bug in the code where it was using single quotes with a
# ruby expression inside the quotes. You must use double quotes in order to
# include a ruby expression inside the quotes.
#
# 'fat model, skinny controller' means that we should prefer pushing code into
# the model rather than an individual controller. Code in a controller can only
# be used by that controller, but code in the model can be used by any
# controller.
# This rule of thumb aids in code re-use and keeping controllers simpler and
# easier to read.
####################################################################
class CarsController
 def break_random_wheel
   @car = Car.find_car
   @wheels = @car.find_wheels
   random_wheel =  (rand*4).round
   @wheels[random_wheel].break!
   @car.functioning_wheels -= 1
 end
end

class Car < ActiveRecord::Base
 has_many :components
 def self.find_car
   # class method that replaces call to Car.find in CarsController
   self.find(:first, conditions =>
      ['name = ? AND user = ?', "#{params[:name]}", "#{params[:user_id]}"])

 end
 def find_wheels
   # instance method that replaces call to car.components.find
   car = self.find_car
   wheels = @car.components.find(:all, :conditions => "type = 'wheel'")
 end
end

class User < ActiveRecord::Base
end

# Problem 3. You are running a Rails application with 2 workers (imagine a 2-mongrel cluster or a Passenger with 2 passenger workers).
# You have code that looks like this

class CarsController
 def start_engine
  @car = Car.first # bonus: there is a bug here. what is it?
  # bug is that only the first car returned from the database will be started.
  # the start_engine method should have a condition for matching an id
  # parameter. Currently it will always start whichever car the database
  # returns as the first car.
  @car.start_engine
 end
end

class Car < ActiveRecord::Base
 def start_engine
  api_url = "http://my.cars.com/start_engine?id={self.id}"
  RestClient.post api_url
 end
end

# 3a. Explain what possible problems could arise when a user hits this code.

####################################################################
# Since start_engine is a class method, two different workers could
# assign api_url at the same time and one assignment would get lost
# and the same car would get started by both workers. In other words,
# the statements in Car's start_engine method could be interleaved
####################################################################

# 3b. Imagine now that we have changed the implementation:

class CarsController
 def start_engine
  sleep(30)
 end
 def drive_away
  sleep(10)
 end
 def status
  sleep(5)
  render :text => "All good!"
 end
end

# Continued...Now you are running your 2-worker app server in production.
#
# Let's say 5 users (call them x,y,z1,z2,z3), hit the following actions in order, one right after the other.
# x: goes to start_engine
# y: goes to drive_away
# z1: goes to status
# z2: goes to status
# z3: goes to status
#
# Explain approximately how long it will take for each user to get a response back from the server.
#
# Example: user 'x' will take about 30 seconds. What about y,z1,z2,z3?
#
# user 'y' will take about 40 seconds.
# user 'z1' will take about 45 seconds.
# user 'z2' will take about 50 seconds.
# user 'z3' will take about 55 seconds.
#
# Approximately how many requests/second can your cluster process for the action 'start_engine'? What about 'drive_away'?
# What could you do to increase the throughput (requests/second)?
#
# 'start_engine' can process about 0.033 requests per second.
# 'drive_away' can process 0.10 requests per second.
# To increase throughput, we could program these delays on the front-end (view)
# using javascript and maybe AJAX, instead of in the controller.

# Problem 4. Here's a piece of code to feed my pets. Please clean it up as you see fit.

cat = Cat.new
dog = Dog.new
cow = Cow.new
my_pets = [cat, dog, cow, ]
my_pet_food = [:milk, :dogfood, :grass, ]
feed_pets(my_pets, my_pet_food)

def feed_pets(pets, food)
 pets.each do |pet|
   food.each do |food|
     pet.feed(food)
   end
 end
end

class Pet
 def feed(food)
   puts "thanks!"
 end
end

class Cat < Pet
 def feed(food)
   if (food == :milk)
     puts "yummy milk"
   else
     puts "yuck, I won't eat that"
   end
 end
end

class Dog < Pet
 def feed(food)
   if (food == :dogfood)
     puts "yummy dogfood"
   else
     puts "yuck, I won't eat that"
   end
 end
end

class Cow < Pet
 def feed(food)
   if (food == :grass)
     puts "yummy grass"
   else
     puts "yuck, I won't eat that"
   end
 end
end

# Problem 5. Improve this code

class ArticlesController < ApplicationController
 def index
  @articles = Article.find_all_by_state(Article::STATES[:published], :order => "created_at DESC")
 end
end

class Article < ActiveRecord::Base

end

# Problem 6. Explain in a few sentences the difference between a ruby Class and Module and when it's appropriate to use either one.

####################################################################
# A ruby class is like a class in any OOP language, while a module
# contains method and constant definitions, some of which can be
# called from any piece of code. Other module components can
# be mixed-into a class. Modules serve two purposes: they can package
# related methods and constants for easy access from any code. They can
# also be mixed into a class to conveniently add functionality. Classes
# are best for defining the main types in your domain. Modules are best
# for packaging stand-alone definitions and generalized definitions that
# can be useful to multiple classes, when mixed-in.
####################################################################


# Problem 7. Explain the problem with this code

####################################################################
# Method 'find(:all)' will return an array of objects.
# Calling the select method on the array of objects passing in the code
# block below, only the records that return true should be in the final
# result array.
# From my point of view, it's preferable to work with ActiveRelations
# instead of an array of User objects. Any problems arise because
# we're working with an array of objects instead of an ActiveRelation.
####################################################################

class UsersController
 def find_active_users
  User.find(:all).select {|user| user.active?}
 end
end

# Problem 8. Explain what's wrong with this code and fix it. (Hint: named_scope)

####################################################################
#
####################################################################

class User < ActiveRecord::Base
 has_many :cars

 def red_cars
  cars.scoped(:color, :conditions => ["color = ?"], 'red')
 end

 def green_cars
  cars.scoped(:color, :conditions => ["color = ?"], 'green')
 end
end

class Car < ActiveRecord::Base
 belongs_to :user
end

# Problem 9. Here's a piece of code that does several actions. You can see that it has duplicated
# error handling, logging, and timeout handling. Design a block helper method that will remove
# the duplication, and refactor the code to use the block helper.

def logger_block_helper(action_text, time_amount, action)
  logger.info "About do do #{action_text}"
  Timeout::timeout(time_amount) do
    begin
      action
    rescue => e
      logger.error "Got error: #{e.message}"
    end
end

logger_block_helper("action1", 5, action1)

logger_block_helper("action2", 10, action2)

logger_blockk_helper("action3", 7, action3)

