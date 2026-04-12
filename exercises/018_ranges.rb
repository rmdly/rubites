# Exercise 018: Ranges
#
# Ranges represent intervals: (1..5) includes 5, (1...5) excludes 5.
# They work with numbers, strings, and anything that responds to .succ.
# .to_a converts a range to an array.
#
# Expected output: [1, 2, 3, 4, 5]
# Expected output: [1, 2, 3, 4]
# Expected output: true

# TODO: Create an inclusive range from 1 to 5 and convert to array
inclusive = (1...5).to_a
puts inclusive.inspect

# TODO: Create an exclusive range from 1 to 5 (excludes 5) and convert to array
exclusive = (1..4).to_a
puts exclusive.inspect

# TODO: Check if 3 is included in the range 1..5
puts (1..5).include?(6)
