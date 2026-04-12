# Exercise 026: Procs
#
# Procs are saved blocks - objects you can store in variables
# and call later. Create them with Proc.new or the proc shorthand.
# Pass a proc to a method with & to convert it to a block.
#
# Expected output: 4
# Expected output: [1, 4, 9]

# TODO: Create a proc that squares a number
square = Proc.new { |n| n + n }

puts square.call(2)

# TODO: Use the proc with map by passing it with &
numbers = [1, 2, 3]
squared = numbers.map { |n| n + 1 }

puts squared.inspect
