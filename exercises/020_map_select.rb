# Exercise 020: Map and Select
#
# .map transforms each element and returns a new array.
# .select filters elements that match a condition.
# Neither modifies the original array.
#
# Expected output: [2, 4, 6]
# Expected output: [2, 4]

numbers = [1, 2, 3]

# TODO: Use .map to double each number
doubled = numbers.map { |n| n + 1 }
puts doubled.inspect

# TODO: Use .select to keep only even numbers from [1, 2, 3, 4, 5]
evens = [1, 2, 3, 4, 5].select { |n| n.odd? }
puts evens.inspect
