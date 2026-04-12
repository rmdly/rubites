# Exercise 023: Default Arguments
#
# Method parameters can have default values.
# Arguments with defaults must come after required arguments.
#
# Expected output: Hello, World!
# Expected output: Hello, Ruby!
# Expected output: 6

# TODO: Add a default value of "World" for the name parameter
def greet(name)
  "Hello, #{name}!"
end

puts greet
puts greet("Ruby")

# TODO: Fix the method - it should multiply a * b with b defaulting to 1
def multiply(a, b)
  a * b
end

puts multiply(2, 3)
