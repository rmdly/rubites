# Exercise 006: Ractor — Pipeline
#
# Three Ractors form a message-passing pipeline:
#   source → doubler → adder
#
# Source pushes numbers 1..6 to the doubler.
# Doubler receives each, doubles it, and pushes to the adder.
# Adder receives all doubled numbers and returns their sum.
#
# 2 + 4 + 6 + 8 + 10 + 12 = 42
#
# Critical constraint: Ractor blocks are fully isolated — they cannot
# close over outer variables. Pass data in through Ractor.new(arg) { |arg| }
# or via send/receive messaging.
#
# TODO: The pipeline has the same isolation problem as the worker pool —
# doubler and source reference Ractors defined in the outer scope. Fix both
# so each Ractor receives its downstream reference as an argument.
#
# Expected output: pipeline result: 42

adder = Ractor.new do
  total = 0
  6.times { total += Ractor.receive }
  total
end

doubler = Ractor.new do
  6.times do
    value = Ractor.receive
    adder.send(value * 2)
  end
end

source = Ractor.new do
  (1..6).each { |n| doubler.send(n) }
end

puts "pipeline result: #{adder.value}"
