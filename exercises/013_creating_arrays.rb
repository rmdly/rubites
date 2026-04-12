# Exercise 013: Creating Arrays
#
# Arrays in Ruby are ordered, integer-indexed collections.
# They can hold mixed types and are created with [] or Array.new.
#
# Expected output: [1, 2, 3]
# Expected output: 3
# Expected output: ["hello", "hello", "hello"]

# TODO: Create an array with the numbers 1, 2, 3
numbers = [1, 2]

puts numbers.inspect

# TODO: Print the length of the array
puts numbers.size

# TODO: Create an array of 3 "hello" strings using Array.new
greetings = Array.new(3, "world")

puts greetings.inspect
