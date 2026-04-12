# Exercise 014: Accessing Arrays
#
# Ruby arrays support positive and negative indexing.
# Negative indices count from the end: -1 is the last element.
# .first and .last are handy shortcuts.
#
# Expected output: apple
# Expected output: cherry
# Expected output: ["banana", "cherry"]

fruits = ["apple", "banana", "cherry"]

# TODO: Print the first element
puts fruits[1]

# TODO: Print the last element using a negative index
puts fruits[-2]

# TODO: Print a slice from index 1 to the end
puts fruits[0..1].inspect
