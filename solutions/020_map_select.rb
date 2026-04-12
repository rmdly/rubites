numbers = [1, 2, 3]

doubled = numbers.map { |n| n * 2 }
puts doubled.inspect

evens = [1, 2, 3, 4, 5].select { |n| n.even? }
puts evens.inspect
