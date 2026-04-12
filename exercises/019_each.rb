# Exercise 019: Each
#
# .each is Ruby's most fundamental iterator. It calls a block
# once for each element and returns the original collection.
# Use {..} for single-line blocks and do..end for multi-line.
#
# Expected output: 1
# Expected output: 2
# Expected output: 3
# Expected output: name: Alice
# Expected output: name: Bob

numbers = [1, 2, 3]
names = ["Alice", "Bob"]

# TODO: Use .each to print each number on its own line
numbers.each { |n| puts n * 2 }

# TODO: Use .each to print each name with "name: " prefix
names.each { |name| puts name }
