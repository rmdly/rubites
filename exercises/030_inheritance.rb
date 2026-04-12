# Exercise 030: Inheritance
#
# Use < to inherit from a parent class.
# Call super to invoke the parent's method.
# .is_a? checks if an object is an instance of a class or its ancestors.
#
# Expected output: Buddy says Woof!
# Expected output: true
# Expected output: true

class Animal
  def initialize(name)
    @name = name
  end

  def speak
    "..."
  end
end

# TODO: Fix Dog to inherit from Animal and override speak
class Dog
  def speak
    "#{@name} says Woof!"
  end
end

dog = Dog.new("Buddy")
puts dog.speak

# TODO: Fix these checks
puts dog.is_a?(Dog)
puts dog.is_a?(String)
