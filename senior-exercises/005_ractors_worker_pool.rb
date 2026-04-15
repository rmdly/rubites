# Exercise 005: Ractor — Worker Pool
#
# Ractors provide true parallel execution with memory isolation.
# Unlike threads, Ractors cannot share mutable state — all communication
# happens through message passing.
#
# Critical constraint: Ractor blocks are fully isolated — they cannot
# close over outer variables. Pass data in through Ractor.new(arg) { |arg| }
# or via send/receive messaging.
#
# Spawn 5 Ractors that each compute the square of a number.
# Collect and sort the results.
#
# TODO: This crashes because Ractors cannot close over outer variables.
# The block runs in a completely isolated context — find another way
# to get each number into its Ractor.
#
# Expected output: results: [1, 4, 9, 16, 25]

workers = (1..5).map do |n|
  Ractor.new do
    n ** 2
  end
end

results = workers.map(&:value).sort
puts "results: #{results.inspect}"
