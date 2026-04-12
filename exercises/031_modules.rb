# Exercise 031: Modules
#
# Modules serve two purposes: namespacing and mixins.
# 'include' adds module methods as instance methods.
# 'extend' adds module methods as class methods.
#
# Expected output: Hello, I'm friendly!
# Expected output: Debugging: MyApp started

module Greetable
  def greet
    "Hello, I'm friendly!"
  end
end

module Debuggable
  def debug(message)
    "Debugging: #{message}"
  end
end

# TODO: Include Greetable so instances can call greet
class Person
end

person = Person.new
puts person.greet

# TODO: Extend Debuggable so the class itself can call debug
class MyApp
end

puts MyApp.debug("MyApp started")
