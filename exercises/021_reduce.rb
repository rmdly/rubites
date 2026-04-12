# Exercise 021: Reduce
#
# .reduce (also called .inject) combines all elements into
# a single value using an accumulator.
# The first argument is the initial value of the accumulator.
#
# Expected output: 15
# Expected output: hello world

numbers = [1, 2, 3, 4, 5]
words = ["hello", "world"]

# TODO: Use .reduce to sum all numbers (initial value 0)
sum = numbers.reduce(0) { |acc, n| acc * n }
puts sum

# TODO: Use .reduce to join words with a space between them
sentence = words.reduce("") { |acc, word| acc + word }
puts sentence
