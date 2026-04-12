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

class Person
  include Greetable
end

person = Person.new
puts person.greet

class MyApp
  extend Debuggable
end

puts MyApp.debug("MyApp started")
