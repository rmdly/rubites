# Exercise 004: String Interpolation
#
# Ruby uses #{} inside double-quoted strings to embed expressions.
# Single-quoted strings don't support interpolation.
#
# Expected output: My name is Ruby and I am 31 years old.

name = "Ruby"
age = 31

# TODO: Use string interpolation to build the sentence
sentence = 'My name is #{name} and I am #{age} years old.'

puts sentence
