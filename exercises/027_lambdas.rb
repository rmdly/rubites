# Exercise 027: Lambdas
#
# Lambdas are like procs but stricter: they check argument count
# and 'return' only exits the lambda, not the enclosing method.
# Create them with -> (stabby lambda) or lambda {}.
#
# Expected output: 8
# Expected output: lambda
# Expected output: 2 args required

# TODO: Create a lambda that cubes a number using -> syntax
cube = -> (n) { n * n }

puts cube.call(2)

# TODO: Show that this is a lambda, not a proc
my_lambda = -> { "I'm a lambda" }
puts my_lambda.class == Proc ? "lambda" : "not a proc"

# TODO: Fix this - lambdas enforce argument count
strict = -> (a, b) { a + b }
begin
  strict.call(1)
rescue ArgumentError
  puts "2 args required"
end
