# Exercise 024: Implicit Return
#
# Ruby methods return the value of their last expression automatically.
# You don't need 'return' unless you want to exit early.
# This is one of Ruby's most distinctive features.
#
# Expected output: 15
# Expected output: negative
# Expected output: zero

# TODO: Fix the method - it should return the sum, not print it
def add(a, b)
  result = a + b
  puts result
end

puts add(5, 10)

# TODO: Fix the early return - should return "negative" for numbers < 0,
# "zero" for 0, and "positive" for numbers > 0
def describe_number(n)
  return "positive" if n < 0
  return "negative" if n == 0
  "zero"
end

puts describe_number(-5)
puts describe_number(0)
