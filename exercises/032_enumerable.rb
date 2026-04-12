# Exercise 032: Enumerable
#
# Include Enumerable in your class and define #each to get
# dozens of methods for free: map, select, sort, min, max, etc.
# This is one of Ruby's most powerful patterns.
#
# Expected output: [1, 3, 5]
# Expected output: 1
# Expected output: 5

class NumberBag
  include Enumerable

  def initialize(*numbers)
    @numbers = numbers
  end

  # TODO: Define #each so it yields each number from @numbers
end

bag = NumberBag.new(5, 3, 1)

# These all work for free once #each is defined:
puts bag.sort.inspect
puts bag.min
puts bag.max
