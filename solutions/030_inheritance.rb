class Animal
  def initialize(name)
    @name = name
  end

  def speak
    "..."
  end
end

class Dog < Animal
  def speak
    "#{@name} says Woof!"
  end
end

dog = Dog.new("Buddy")
puts dog.speak

puts dog.is_a?(Dog)
puts dog.is_a?(Animal)
