# Exercise 010: If and Unless
#
# Ruby has if/elsif/else like most languages.
# It also has 'unless', which is like a negated if.
# Both can be used as trailing modifiers too.
#
# Expected output: adult
# Expected output: too cold

age = 20
temperature = 10

# TODO: Fix the condition - should print "adult" when age >= 18
if age < 18
  puts "adult"
else
  puts "minor"
end

# TODO: Use 'unless' to print "too cold" when temperature is below 15
if temperature >= 15
  puts "too cold"
end
