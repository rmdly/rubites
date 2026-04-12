cube = -> (n) { n ** 3 }

puts cube.call(2)

my_lambda = -> { "I'm a lambda" }
puts my_lambda.class == Proc ? "lambda" : "not a proc"

strict = -> (a, b) { a + b }
begin
  strict.call(1)
rescue ArgumentError
  puts "2 args required"
end
