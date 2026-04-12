# Exercise 029: Attr Accessor
#
# attr_reader creates getter methods, attr_writer creates setters,
# and attr_accessor creates both. These save you from writing
# boilerplate getter/setter methods.
#
# Expected output: Alice
# Expected output: 31
# Expected output: Bob

# TODO: Fix the class - name should be readable, age should be readable AND writable
class Person
  attr_writer :name
  attr_reader :age

  def initialize(name, age)
    @name = name
    @age = age
  end
end

person = Person.new("Alice", 30)
puts person.name
person.age = 31
puts person.age

# TODO: Use attr_accessor so both reading and writing work
class User
  attr_reader :username

  def initialize(username)
    @username = username
  end
end

user = User.new("Alice")
user.username = "Bob"
puts user.username
