class NumberBag
  include Enumerable

  def initialize(*numbers)
    @numbers = numbers
  end

  def each(&block)
    @numbers.each(&block)
  end
end

bag = NumberBag.new(5, 3, 1)

puts bag.sort.inspect
puts bag.min
puts bag.max
