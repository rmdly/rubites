# Exercise 009: Truthiness
#
# In Ruby, only nil and false are falsy. Everything else is truthy.
# This means 0, "", and [] are all truthy (unlike some other languages!).
#
# Expected output: zero is truthy
# Expected output: empty string is truthy
# Expected output: nil is falsy

# TODO: Fix the conditions so the output matches

if 0
  puts "zero is truthy"
else
  puts "zero is falsy"
end

if ""
  puts "empty string is truthy"
else
  puts "empty string is falsy"
end

# TODO: Change this value so it's falsy
value = 0

if value
  puts "value is truthy"
else
  puts "nil is falsy"
end
