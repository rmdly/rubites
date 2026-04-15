# Exercise 002: Ractors
#
# Ractors (Ruby Actors) provide true parallel execution with memory isolation.
# Unlike threads, Ractors cannot share mutable state — all communication
# happens through message passing.
#
# Core API:
#   ractor.send(msg)   — pushes a message into the ractor's inbox
#   Ractor.receive     — inside a ractor, blocks until a message arrives
#   ractor.value       — blocks until the ractor terminates, returns its
#                        final expression (like Thread#value)
#
# Critical constraint: Ractor blocks are fully isolated — they cannot
# close over outer variables. Pass data in through Ractor.new(arg) { |arg| }
# or via send/receive messaging.
#
# Expected output: square of 7 is 49
# Expected output: results: [1, 4, 9, 16, 25]
# Expected output: pipeline result: 42

# --- Part 1: Messaging basics ---
#
# This worker receives a number, squares it, and returns the result.
# The caller pushes a value in with send, and retrieves the final
# result once the Ractor terminates.
#
# TODO: The caller retrieves the result with the wrong method.
# In Ruby 4, Ractors return their final value through .value,
# just like Thread#value.
worker = Ractor.new do
  value = Ractor.receive
  value ** 2
end

worker.send(7)
puts "square of 7 is #{worker.take}"

# --- Part 2: Worker pool ---
#
# Spawn 5 Ractors that each compute the square of a number.
# Collect and sort the results.
#
# TODO: This crashes because Ractors cannot close over outer variables.
# The block runs in a completely isolated context — find another way
# to get each number into its Ractor.
workers = (1..5).map do |n|
  Ractor.new do
    n ** 2
  end
end

results = workers.map(&:value).sort
puts "results: #{results.inspect}"

# --- Part 3: Ractor pipeline ---
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
# TODO: The pipeline has the same isolation problem as Part 2 — doubler
# and source reference Ractors defined in the outer scope. Fix both so
# each Ractor receives its downstream reference as an argument.
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
