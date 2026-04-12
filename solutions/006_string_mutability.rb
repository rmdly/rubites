greeting = "hello"

greeting.upcase!

puts greeting

original = greeting.dup

puts greeting == original

greeting.freeze
puts greeting.frozen?
