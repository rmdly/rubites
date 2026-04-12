class Person
  attr_reader :name
  attr_accessor :age

  def initialize(name, age)
    @name = name
    @age = age
  end
end

person = Person.new("Alice", 30)
puts person.name
person.age = 31
puts person.age

class User
  attr_accessor :username

  def initialize(username)
    @username = username
  end
end

user = User.new("Alice")
user.username = "Bob"
puts user.username
