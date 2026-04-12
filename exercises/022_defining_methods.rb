# Exercise 022: Defining Methods
#
# Methods in Ruby are defined with def..end.
# Method names use snake_case by convention.
# Parentheses around arguments are optional but recommended.
#
# Expected output: Hello, Alice!
# Expected output: 25

# TODO: Fix the method so it greets the given name
def greet(name)
  "Hello, #{name}!"
end

puts greet("Alice")

# TODO: Fix the method to return the square of a number
def square(n)
  n * 2
end

puts square(5)
