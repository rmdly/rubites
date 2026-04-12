# Exercise 028: Classes
#
# Classes are defined with class..end. The initialize method
# is Ruby's constructor. Instance variables start with @.
# .new creates an instance and calls initialize.
#
# Expected output: Fido is 3 years old

# TODO: Fix the class so it stores name and age
class Dog
  def initialize(name)
    @name = name
  end

  def describe
    "#{@name} is #{@age} years old"
  end
end

dog = Dog.new("Fido", 3)
puts dog.describe
