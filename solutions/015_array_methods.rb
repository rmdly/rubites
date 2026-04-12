numbers = [1, 2, 3]

numbers.push(4)

puts numbers.inspect

puts numbers.include?(3)

nested = [[1, 2], [3, [4, 5]]]
result = nested.flatten

puts result.inspect
