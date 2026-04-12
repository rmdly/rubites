def greet(name = "World")
  "Hello, #{name}!"
end

puts greet
puts greet("Ruby")

def multiply(a, b = 1)
  a * b
end

puts multiply(2, 3)
