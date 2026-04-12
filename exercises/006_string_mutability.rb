# Exercise 006: String Mutability
#
# Ruby strings are mutable - you can change them in place.
# Methods ending in ! modify the original string.
# .freeze makes a string immutable.
#
# Expected output: HELLO
# Expected output: true
# Expected output: true

greeting = "hello"

# TODO: Upcase greeting in place (modify the original string)
greeting.upcase

puts greeting

original = greeting.dup

# TODO: Check if greeting and original have the same value
puts greeting == "something wrong"

# TODO: Freeze greeting and check if it's frozen
puts greeting.frozen?
