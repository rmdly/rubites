square = Proc.new { |n| n * n }

puts square.call(2)

numbers = [1, 2, 3]
squared = numbers.map(&square)

puts squared.inspect
