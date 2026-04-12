numbers = [1, 2, 3, 4, 5]
words = ["hello", "world"]

sum = numbers.reduce(0) { |acc, n| acc + n }
puts sum

sentence = words.reduce { |acc, word| "#{acc} #{word}" }
puts sentence
