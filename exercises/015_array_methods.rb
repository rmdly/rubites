# Exercise 015: Array Methods
#
# Ruby arrays have tons of useful methods.
# .push/.pop for the end, .unshift/.shift for the beginning.
# .include? checks membership, .flatten removes nesting.
#
# Expected output: [1, 2, 3, 4]
# Expected output: true
# Expected output: [1, 2, 3, 4, 5]

numbers = [1, 2, 3]

# TODO: Add 4 to the end of the array
numbers.pop

puts numbers.inspect

# TODO: Check if the array includes 3
puts numbers.include?(5)

# TODO: Flatten the nested array
nested = [[1, 2], [3, [4, 5]]]
result = nested

puts result.inspect
