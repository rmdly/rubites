class Dog
  def initialize(name, age)
    @name = name
    @age = age
  end

  def describe
    "#{@name} is #{@age} years old"
  end
end

dog = Dog.new("Fido", 3)
puts dog.describe
