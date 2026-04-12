# Exercise 012: Ternary Operator
#
# Ruby's ternary operator works like most languages:
# condition ? value_if_true : value_if_false
#
# Expected output: even
# Expected output: positive

number = 4
value = 10

# TODO: Fix the ternary so even numbers print "even"
result = number.odd? ? "even" : "odd"
puts result

# TODO: Write a ternary that prints "positive" if value > 0, otherwise "non-positive"
puts value > 0 ? "non-positive" : "positive"
